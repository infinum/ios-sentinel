//
//  AnnotationOverlayWindow.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// The window the capture overlay lives in.
///
/// A window of its own, rather than a view added to the app's own hierarchy, for two reasons:
/// the overlay is then never part of the tree target resolution walks, and it survives the host
/// app replacing its root view controller.
///
/// Touches that land on neither a marker badge nor the overlay's own chrome are refused, so they
/// fall through to the app's window and the app stays fully usable while notes are on screen.
final class AnnotationOverlayWindow: UIWindow {

    // MARK: - Lifecycle

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        backgroundColor = .clear
        // Above the app's own windows, below the system's alert level so an alert is never
        // covered by a marker.
        windowLevel = UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue + 1)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Touch handling

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        // Neither the window nor its otherwise-empty root view is ever a target itself; only the
        // overlay's own subviews are. Refusing those two is what makes the window pass through.
        guard hit !== self, hit !== rootViewController?.view else { return nil }
        return hit
    }
}

#endif
