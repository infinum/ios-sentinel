//
//  CALayer+ScreenFrame.swift
//  Sentinel
//
//  Created by Sentinel on 08/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

extension CALayer {

    /// The view whose backing layer this layer sits under.
    ///
    /// A SwiftUI drawing layer's own `delegate` is a `_SwiftUILayerDelegate`, not a view, so the
    /// owning view is found by walking outward to the first layer a `UIView` backs. That view is
    /// what turns layer coordinates into screen ones.
    var sentinelHostView: UIView? {
        var current: CALayer? = self
        while let layer = current {
            if let view = layer.delegate as? UIView {
                return view
            }
            current = layer.superlayer
        }
        return nil
    }

    /// The layer's rectangle in screen coordinates, or `.zero` when it is not on screen.
    var sentinelScreenFrame: CGRect {
        guard let host = sentinelHostView, let window = host.window else { return .zero }
        // A layer's own frame is in its superlayer's space, so it is lifted into the host view's
        // space first and only then into the window's and the screen's.
        let inHost = convert(bounds, to: host.layer)
        return window.convert(host.convert(inHost, to: nil), to: nil)
    }

    /// Whether the layer is currently on screen and drawing something.
    var isSentinelVisible: Bool {
        guard isSentinelDisplayable, superlayer != nil else { return false }
        return sentinelHostView?.isSentinelVisible ?? false
    }

    /// Whether the layer draws at all, ignoring whether its host is in a window.
    var isSentinelDisplayable: Bool {
        !isHidden && opacity > 0.01 && !bounds.isEmpty
    }
}

#endif
