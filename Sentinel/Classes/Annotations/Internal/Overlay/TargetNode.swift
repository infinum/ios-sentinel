//
//  TargetNode.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import CoreGraphics
import Foundation

/// A toolkit-independent view of one annotatable element.
///
/// `UIViewTargetNode` adapts a `UIView` to this. Every selection rule in `TargetSelection` is
/// written against this protocol, so the rules can be exercised without a live view hierarchy.
///
/// `children` must be ordered back to front — the last child draws on top.
///
/// `parent` is deliberately weak in the concrete implementation, so a tree holds no cycles. A
/// node handed out on its own is therefore only as long-lived as the root it came from, which
/// is why `ResolvedTarget` carries the root along.
protocol TargetNode: AnyObject {

    /// View class name, without its module prefix.
    var type: String { get }

    /// The element's accessibility identifier, when it has one.
    var accessibilityIdentifier: String? { get }

    /// The element's accessibility label, when it has one.
    var accessibilityLabel: String? { get }

    /// Visible text, when the element shows any.
    var text: String? { get }

    /// The app's own SwiftUI view type hosting this element, when there is one.
    var swiftUIType: String? { get }

    /// Which toolkit drew this element.
    var toolkit: AnnotationToolkit { get }

    /// Whether this element is worth selecting, as opposed to framework scaffolding.
    var isAnnotatable: Bool { get }

    /// Whether broadening the selection may stop at this node.
    ///
    /// Defaults to ``isAnnotatable``; an implementation widens it when it has nodes worth
    /// broadening *to* without being worth picking outright — layout containers, typically.
    var isBroadenable: Bool { get }

    /// The element's rectangle in screen coordinates.
    var screenFrame: CGRect { get }

    var children: [TargetNode] { get }

    var parent: TargetNode? { get }
}

extension TargetNode {

    var isBroadenable: Bool { isAnnotatable }
}

#endif
