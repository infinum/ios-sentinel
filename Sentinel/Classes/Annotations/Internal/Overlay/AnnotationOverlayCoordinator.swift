//
//  AnnotationOverlayCoordinator.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import Combine
import SwiftUI
import UIKit

/// Owns the capture overlay for the app process's lifetime.
///
/// The overlay window is created when capture is armed or a note exists, and torn down when
/// neither needs it, so an app with no annotations pays nothing. Marker positions are recomputed
/// from a `CADisplayLink`, which tracks scrolling, keyboard insets and rotation without a special
/// case for any of them.
///
/// The display link runs for as long as the overlay is attached, so ``refresh()`` is on the
/// frame budget: it reads frames off already-bound views and walks nothing, and the one path
/// that does walk the hierarchy — a rebind — is guarded by ``failedRebinds`` so it happens at
/// most once per screen per note. It also returns immediately while the Sentinel panel is up.
///
/// Sentinel's own panel is never annotated: the overlay hides itself while the panel is on
/// screen.
final class AnnotationOverlayCoordinator {

    // MARK: - Internal properties

    static let shared = AnnotationOverlayCoordinator()

    // MARK: - Private properties

    private let store: AnnotationStore
    private let resolver: TargetResolver

    private var cancellables = Set<AnyCancellable>()
    private var window: AnnotationOverlayWindow?
    private var controller: AnnotationOverlayViewController?
    private var displayLink: CADisplayLink?
    private var isStarted = false

    private var selected: ResolvedTarget?

    /// The element the current selection chain started from — the hit of the tap that began it —
    /// kept so repeated taps on the same spot keep broadening instead of resetting.
    ///
    /// Held as the live handle rather than a ``TargetNode``: each tap rebuilds the node tree, so
    /// node identity is not stable across taps, while the element underneath it is.
    private weak var selectionAnchor: AnnotationTargetHandle?

    /// Ids of the notes whose rebind already failed on the current screen.
    ///
    /// ``refresh()`` runs from a display link, so without this a note that cannot re-bind here —
    /// the ordinary "annotated on one screen, navigated to another" case — would re-walk the
    /// whole view hierarchy on every single frame. Cleared whenever the stored notes change or
    /// the screen does, so a retry costs at most one walk per screen.
    private var failedRebinds = Set<String>()

    private var lastScreenName: String?

    private weak var previousKeyWindow: UIWindow?

    // MARK: - Lifecycle

    private init(store: AnnotationStore = .shared, resolver: TargetResolver = UIViewTargetResolver()) {
        self.store = store
        self.resolver = resolver
    }

    // MARK: - Internal methods

    /// Begins observing the store. Idempotent, so every ``AnnotationsTool`` instance may call it.
    func start() {
        guard !isStarted else { return }
        isStarted = true

        // Delivered on the next main-loop turn on purpose: `@Published` fires in `willSet`, so a
        // synchronous sink would read the store's *previous* contents from `refresh()`.
        Publishers.CombineLatest(store.$annotations, store.$isCaptureActive)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] annotations, isCaptureActive in
                self?.sync(annotations: annotations, isCaptureActive: isCaptureActive)
            }
            .store(in: &cancellables)
    }

    // MARK: - Private methods — attach and detach

    private func sync(annotations: [SentinelAnnotation], isCaptureActive: Bool) {
        guard isCaptureActive || !annotations.isEmpty else {
            teardown()
            return
        }
        guard let controller = attachIfNeeded() else { return }

        controller.overlayView.isCaptureActive = isCaptureActive
        controller.stopButton.isHidden = !isCaptureActive
        if !isCaptureActive {
            clearSelection()
        }
        // The stored notes changed, so a rebind that failed against the previous list may now
        // succeed. Cheap: this runs on store changes, never per frame.
        failedRebinds.removeAll()
        refresh()
    }

    private func attachIfNeeded() -> AnnotationOverlayViewController? {
        // A window whose scene is gone can never draw again. Rebuild against the live scene.
        if let existing = window, existing.windowScene == nil {
            teardown()
        }
        if let controller = controller {
            return controller
        }
        guard let scene = activeWindowScene() else { return nil }

        let overlayWindow = AnnotationOverlayWindow(windowScene: scene)
        let overlayController = AnnotationOverlayViewController()
        overlayWindow.rootViewController = overlayController
        overlayWindow.isHidden = false

        overlayController.overlayView.onCaptureTap = { [weak self] point in
            self?.handleCaptureTap(at: point)
        }
        overlayController.overlayView.onBadgeTap = { [weak self] annotation in
            self?.editNote(for: annotation)
        }
        overlayController.inspectCard.onAddNote = { [weak self] in
            self?.addNoteForSelection()
        }
        overlayController.stopButton.onStop = { [weak self] in
            self?.store.isCaptureActive = false
        }
        overlayController.stopButton.onReopen = {
            Sentinel.shared.presentPanel()
        }

        let link = CADisplayLink(target: self, selector: #selector(refresh))
        link.add(to: .main, forMode: .common)

        window = overlayWindow
        controller = overlayController
        displayLink = link
        return overlayController
    }

    private func teardown() {
        displayLink?.invalidate()
        displayLink = nil
        restoreKeyWindow()
        window?.isHidden = true
        window?.rootViewController = nil
        window = nil
        controller = nil
        selected = nil
        selectionAnchor = nil
        failedRebinds.removeAll()
        lastScreenName = nil
    }

    // MARK: - Private methods — per-frame refresh

    /// Recomputes marker positions from the live views, and re-binds notes whose element was
    /// recreated. Only frames are read here — no hierarchy walk — so this stays cheap per frame.
    @objc private func refresh() {
        guard let overlayWindow = window, let controller = controller else { return }

        if overlayWindow.windowScene == nil {
            teardown()
            sync(annotations: store.annotations, isCaptureActive: store.isCaptureActive)
            return
        }

        let isPanelShown = Sentinel.shared.isPanelShown
        overlayWindow.isHidden = isPanelShown
        guard !isPanelShown, let host = hostWindow() else { return }

        let screen = ScreenIdentity.screenName(in: host)
        if screen != lastScreenName {
            lastScreenName = screen
            failedRebinds.removeAll()
        }

        controller.overlayView.markers = markers(for: store.annotations, host: host, screen: screen)
    }

    private func markers(
        for annotations: [SentinelAnnotation],
        host: UIWindow,
        screen: String?
    ) -> [AnnotationMarker] {
        annotations.enumerated().compactMap { index, annotation in
            guard annotation.screen == nil || annotation.screen == screen else { return nil }
            guard let frame = screenFrame(for: annotation, host: host) else { return nil }
            return AnnotationMarker(number: index + 1, screenFrame: frame, annotation: annotation)
        }
    }

    /// Frame of `annotation`'s live element, without walking the hierarchy when it can be
    /// avoided.
    ///
    /// A live, on-screen handle is read directly — that is what keeps the per-frame refresh
    /// cheap. Only when it is stale (released, detached or hidden) does this fall back to a
    /// rebind, which does walk the hierarchy; that cost is paid only for the notes needing it.
    private func screenFrame(for annotation: SentinelAnnotation, host: UIWindow) -> CGRect? {
        if let frame = store.target(for: annotation.id)?.sentinelLiveScreenFrame {
            return frame
        }
        guard !failedRebinds.contains(annotation.id) else { return nil }
        guard let rebound = resolver.rebind(annotation, root: host) else {
            failedRebinds.insert(annotation.id)
            return nil
        }
        store.bind(id: annotation.id, to: rebound.handle)
        return rebound.node.screenFrame
    }

    // MARK: - Private methods — selection

    /// A tap on the already-selected element broadens the selection one step toward the screen
    /// root, and wraps back to the deepest target past the outermost one. Anything else selects
    /// afresh.
    ///
    /// Selecting never opens the note sheet: that would make broadening unreachable, because the
    /// second tap would land on the sheet instead of the element. The sheet is opened from the
    /// inspect card's "Add note" action.
    private func handleCaptureTap(at screenPoint: CGPoint) {
        guard let host = hostWindow() else { return }
        guard let fresh = resolver.resolve(root: host, at: screenPoint) else { return }

        // Broaden only when this tap resolves to the element the chain started from. Comparing
        // against the *current* selection cannot work: `resolve` always returns the deepest
        // node, so after one step up the two never match again and every further tap would
        // reset instead of continuing up the tree.
        let next: ResolvedTarget
        if let current = selected, fresh.handle === selectionAnchor {
            next = stepUp(from: current) ?? fresh
        } else {
            selectionAnchor = fresh.handle
            next = fresh
        }

        selected = next
        controller?.overlayView.selection = next.node.screenFrame
        showInspectCard(for: next)
    }

    /// `current` broadened one annotatable step toward the root, or `nil` when it is already the
    /// outermost one — the caller then wraps back to the deepest target under the tap.
    ///
    /// The stepped-to node brings its own live handle: reusing `current`'s would leave a note,
    /// once saved, pointing at — and its marker drawn around — the narrower element first tapped
    /// rather than the one the user actually broadened to.
    private func stepUp(from current: ResolvedTarget) -> ResolvedTarget? {
        guard let stepped = TargetSelection.stepUp(from: current.node),
              let handle = TargetNodeBuilder.handle(of: stepped) else { return nil }
        return ResolvedTarget(root: current.root, node: stepped, handle: handle)
    }

    private func showInspectCard(for target: ResolvedTarget) {
        guard let controller = controller else { return }
        let origin = controller.view.sentinelScreenFrame.origin
        let anchor = target.node.screenFrame.offsetBy(dx: -origin.x, dy: -origin.y)
        controller.inspectCard.show(
            for: target.node,
            anchor: anchor,
            in: controller.view.bounds.inset(by: controller.view.safeAreaInsets)
        )
    }

    private func clearSelection() {
        selected = nil
        selectionAnchor = nil
        controller?.overlayView.selection = nil
        controller?.inspectCard.hide()
    }

    // MARK: - Private methods — notes

    private func addNoteForSelection() {
        guard let target = selected else { return }
        // The card is deliberately left up: the sheet covers it anyway, and hiding it would
        // leave a cancelled note with a selected element and no way to retry but re-tapping it.
        presentNoteSheet(
            targetType: target.node.type,
            initial: nil,
            onSave: { [weak self] note in self?.saveNote(note, for: target) },
            onDelete: nil
        )
    }

    private func editNote(for annotation: SentinelAnnotation) {
        presentNoteSheet(
            targetType: annotation.targetType,
            initial: annotation.note,
            onSave: { [weak self] note in self?.store.updateNote(id: annotation.id, note: note) },
            onDelete: { [weak self] in self?.store.remove(id: annotation.id) }
        )
    }

    private func saveNote(_ note: String, for target: ResolvedTarget) {
        guard let host = hostWindow() else { return }

        // Counted against the target's own tree, which `ResolvedTarget` carries. Building a fresh
        // tree here would hold different node objects for the same views, so the ordinal — found
        // by identity — would never locate it and every note would be stamped as position 1.
        let position = TargetSelection.ordinal(of: target.node, in: target.root)
        let frame = target.node.screenFrame
        let center = CGPoint(x: frame.midX, y: frame.midY)

        store.add(
            SentinelAnnotation(
                note: note,
                toolkit: target.toolkit,
                targetType: target.node.type,
                targetPath: TargetSelection.path(of: target.node),
                accessibilityIdentifier: target.node.accessibilityIdentifier,
                accessibilityLabel: target.node.accessibilityLabel,
                swiftUIType: target.node.swiftUIType,
                ordinal: position.ordinal,
                ordinalCount: position.count,
                text: target.node.text,
                screen: ScreenIdentity.screenName(in: host),
                viewController: ScreenIdentity.viewControllerName(in: host, containing: center),
                bounds: ElementBounds(frame),
                rebindPoint: center
            ),
            target: target.handle
        )
        clearSelection()
    }

    private func presentNoteSheet(
        targetType: String,
        initial: String?,
        onSave: @escaping (String) -> Void,
        onDelete: (() -> Void)?
    ) {
        guard let controller = controller, let overlayWindow = window else { return }
        guard controller.presentedViewController == nil else { return }

        previousKeyWindow = hostWindow()
        // Text input needs the overlay window to be key, or the keyboard would be handed to the
        // app's own window and the field would never receive a character.
        overlayWindow.makeKeyAndVisible()

        var hosting: UIHostingController<AnnotationNoteSheet>?
        let dismiss: () -> Void = { [weak self] in
            hosting?.dismiss(animated: true)
            self?.restoreKeyWindow()
        }

        let sheet = AnnotationNoteSheet(
            targetType: targetType,
            initial: initial ?? "",
            canDelete: onDelete != nil,
            onSave: { note in
                onSave(note)
                dismiss()
            },
            onDelete: onDelete == nil ? nil : {
                onDelete?()
                dismiss()
            },
            onCancel: dismiss
        )

        let presented = UIHostingController(rootView: sheet)
        // A swipe dismissal would skip `dismiss()` and leave the overlay as the key window, so
        // the app would keep losing the keyboard. The sheet has an explicit Cancel instead.
        presented.isModalInPresentation = true
        hosting = presented
        controller.present(presented, animated: true)
    }

    // MARK: - Private methods — windows

    private func activeWindowScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    /// The app's own window, the one target resolution runs against.
    ///
    /// The key-window test is only the first choice: while the note sheet is up the overlay
    /// itself is key, and the app's window has to be found some other way.
    private func hostWindow() -> UIWindow? {
        guard let scene = window?.windowScene ?? activeWindowScene() else { return nil }
        let candidates = scene.windows.filter { !($0 is AnnotationOverlayWindow) }
        return candidates.first { $0.isKeyWindow } ?? candidates.first { !$0.isHidden }
    }

    private func restoreKeyWindow() {
        previousKeyWindow?.makeKeyAndVisible()
        previousKeyWindow = nil
    }
}

#endif
