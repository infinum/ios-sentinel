//
//  AnnotationStore.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import Combine
import UIKit

/// Holds the captured notes in memory for the app process's lifetime.
///
/// Notes do not survive process death. This is a deliberate limitation carried over from the
/// Flutter library this feature is ported from: a note's value is tied to a live element it can
/// be re-bound to.
///
/// Main-thread only. Every mutation publishes, and both the overlay and the Annotations screen
/// observe it, so it is UI state and is treated as such.
final class AnnotationStore: ObservableObject {

    // MARK: - Internal properties

    static let shared = AnnotationStore()

    /// Single source of truth for whether capture mode is armed.
    @Published var isCaptureActive = false

    @Published private(set) var annotations: [SentinelAnnotation] = []

    // MARK: - Private properties

    private enum Constants {
        static let alphabet = Array("abcdefghijklmnopqrstuvwxyz0123456789")
        static let idLength = 8
    }

    /// Live handles to the annotated views, keyed by annotation id.
    ///
    /// Weak, and held outside ``SentinelAnnotation`` on purpose: this cache lives as long as the
    /// process, and a `UIView` reaches its view controller through the responder chain. A strong
    /// handle would keep a dismissed screen alive for as long as its note existed, and report as
    /// a leak in the consumer's own app.
    private var targets: [String: WeakViewBox] = [:]

    // MARK: - Lifecycle

    private init() {}

    // MARK: - Internal methods

    /// Stores `annotation`, assigning an id when it has none. Returns the stored copy.
    @discardableResult
    func add(_ annotation: SentinelAnnotation, target: UIView?) -> SentinelAnnotation {
        var stored = annotation
        if stored.id.isEmpty {
            stored.id = generateID()
        }
        annotations.append(stored)
        bind(id: stored.id, to: target)
        return stored
    }

    func updateNote(id: String, note: String) {
        guard let index = annotations.firstIndex(where: { $0.id == id }) else { return }
        annotations[index].note = note
    }

    func remove(id: String) {
        guard annotations.contains(where: { $0.id == id }) else { return }
        annotations.removeAll { $0.id == id }
        targets[id] = nil
    }

    func clear() {
        guard !annotations.isEmpty else { return }
        annotations.removeAll()
        targets.removeAll()
    }

    /// Flags only the annotations whose id is in `ids` as sent. Everything else is untouched.
    ///
    /// Rebuilt and assigned once rather than mutated element by element: `annotations` is
    /// published, so an in-place loop would notify every observer once per marked note.
    func markSent(ids: [String]) {
        let sent = Set(ids)
        guard annotations.contains(where: { !$0.isSent && sent.contains($0.id) }) else { return }
        annotations = annotations.map { annotation in
            guard !annotation.isSent, sent.contains(annotation.id) else { return annotation }
            var updated = annotation
            updated.isSent = true
            return updated
        }
    }

    /// Re-points a note at a freshly created view after navigating back to its screen.
    func bind(id: String, to view: UIView?) {
        guard let view = view else {
            targets[id] = nil
            return
        }
        targets[id] = WeakViewBox(view: view)
    }

    /// The live view a note points at, or `nil` once it has been released.
    func target(for id: String) -> UIView? {
        guard let box = targets[id] else { return nil }
        guard let view = box.view else {
            targets[id] = nil
            return nil
        }
        return view
    }

    // MARK: - Private methods

    /// Short opaque id, unique among the notes currently stored. Nothing parses its shape.
    private func generateID() -> String {
        var candidate: String
        repeat {
            candidate = String((0..<Constants.idLength).map { _ in
                Constants.alphabet[Int.random(in: 0..<Constants.alphabet.count)]
            })
        } while annotations.contains(where: { $0.id == candidate })
        return candidate
    }
}

// MARK: - Weak box

private final class WeakViewBox {

    weak var view: UIView?

    init(view: UIView) {
        self.view = view
    }
}

#endif
