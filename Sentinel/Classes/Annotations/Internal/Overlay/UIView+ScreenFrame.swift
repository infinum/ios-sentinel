//
//  UIView+ScreenFrame.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

extension UIView {

    /// The view's rectangle in screen coordinates, or `.zero` when it is not in a window.
    ///
    /// Screen rather than window coordinates because the capture overlay lives in a window of
    /// its own: with two windows in play, only a shared space lets a tap in one be resolved
    /// against a view in the other.
    var sentinelScreenFrame: CGRect {
        // `convert(_:to: nil)` means "to my window" for a view, but "to the screen" for a
        // window, so a window must not be converted twice.
        if let window = self as? UIWindow {
            return window.convert(window.bounds, to: nil)
        }
        guard let window = window else { return .zero }
        return window.convert(convert(bounds, to: nil), to: nil)
    }

    /// Whether the view is currently on screen and drawing something.
    var isSentinelVisible: Bool {
        window != nil && isSentinelDisplayable
    }

    /// Whether the view draws at all, ignoring whether it is in a window.
    ///
    /// Used while building a tree, where every node is being read from a live hierarchy anyway,
    /// so what matters is only whether the user can see this particular element.
    var isSentinelDisplayable: Bool {
        !isHidden && alpha > 0.01 && !bounds.isEmpty
    }
}

#endif
