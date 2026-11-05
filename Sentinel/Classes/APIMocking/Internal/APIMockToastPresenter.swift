//
//  APIMockToastPresenter.swift
//  Sentinel
//
//  Created by Nikola Simunko on 05.11.2026..
//

#if os(iOS)
import SwiftUI
import UIKit

/// Shows API mocking toasts over the app, in a window of their own so the app's views are left alone.
/// Used from the main thread.
final class APIMockToastPresenter {

    static let shared = APIMockToastPresenter()

    // MARK: - Private properties

    private static let visibleDuration: TimeInterval = 3

    private let model = APIMockToastModel()
    private var window: UIWindow?
    private var hideWork: DispatchWorkItem?
    private var burst = APIMockRequestBurst()
    private var activationObserver: NSObjectProtocol?
}

// MARK: - Showing toasts

extension APIMockToastPresenter {

    /// Shows the toast once a scene is on screen, as the tool is usually made before the app has a window.
    func showWhenActive(_ message: APIMockToastMessage) {
        if activeScene != nil {
            show(message)
            return
        }
        guard activationObserver == nil else { return }
        activationObserver = NotificationCenter.default.addObserver(
            forName: UIScene.didActivateNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            guard let self else { return }
            if let observer = activationObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            activationObserver = nil
            show(message)
        }
    }

    func mockAnswered(_ request: URLRequest, with mock: APIMock) {
        guard APIMockStore.shared.showsRequestToasts else { return }
        show(burst.add(request, mockedBy: mock))
    }

    /// Shows the message, or puts it in place of the one already up, and starts the timer again.
    func show(_ message: APIMockToastMessage) {
        guard let window = window ?? makeWindow() else { return }
        self.window = window
        withAnimation(.easeOut(duration: 0.25)) {
            model.message = message
        }
        UIAccessibility.post(notification: .announcement, argument: "\(message.title), \(message.subtitle)")

        hideWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.hide() }
        hideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.visibleDuration, execute: work)
    }
}

// MARK: - Helpers

private extension APIMockToastPresenter {

    var activeScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }

    func makeWindow() -> UIWindow? {
        guard let scene = activeScene else { return nil }
        let window = APIMockToastWindow(windowScene: scene)
        window.windowLevel = UIWindow.Level.alert + 1
        let controller = UIHostingController(rootView: APIMockToastContainer(model: model))
        controller.view.backgroundColor = UIColor.clear
        window.rootViewController = controller
        window.isHidden = false
        return window
    }

    func hide() {
        withAnimation(.easeIn(duration: 0.25)) {
            model.message = nil
        }
        burst = APIMockRequestBurst()
        // Released after the fade, unless a new toast came in meanwhile.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self, model.message == nil else { return }
            window?.isHidden = true
            window = nil
        }
    }
}

// MARK: - Window

/// Lets every touch through to the app's windows below.
private final class APIMockToastWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }
}

// MARK: - View

private final class APIMockToastModel: ObservableObject {

    @Published var message: APIMockToastMessage?
}

private struct APIMockToastContainer: View {

    @ObservedObject var model: APIMockToastModel

    var body: some View {
        VStack {
            if let message = model.message {
                APIMockToastView(message: message)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

private struct APIMockToastView: View {

    let message: APIMockToastMessage

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(message.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(message.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.orange.opacity(0.6), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityIdentifier.apiMockingToast)
    }
}
#endif
