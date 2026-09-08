//
//  AnnotationTargetHandle.swift
//  Sentinel
//
//  Created by Sentinel on 08/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// A live handle to an annotated element.
///
/// Usually a `UIView`. For SwiftUI-drawn content it is a `CALayer`: SwiftUI creates no backing
/// view for a `Text` or an `Image`, but it does draw each into a layer of its own, and that layer
/// is the only thing on screen that corresponds to what the user tapped.
///
/// Class-bound so the store can hold one weakly: a note outlives the screen it was taken on and
/// must never keep it alive.
protocol AnnotationTargetHandle: AnyObject {

    /// The element's rectangle in screen coordinates, or `nil` once it is no longer on screen.
    var sentinelLiveScreenFrame: CGRect? { get }
}

extension UIView: AnnotationTargetHandle {

    var sentinelLiveScreenFrame: CGRect? {
        guard isSentinelVisible else { return nil }
        return sentinelScreenFrame
    }
}

extension CALayer: AnnotationTargetHandle {

    var sentinelLiveScreenFrame: CGRect? {
        guard isSentinelVisible else { return nil }
        return sentinelScreenFrame
    }
}

#endif
