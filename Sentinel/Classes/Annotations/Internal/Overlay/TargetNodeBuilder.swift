//
//  TargetNodeBuilder.swift
//  Sentinel
//
//  Created by Sentinel on 08/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// Turns a layer's sublayers into target nodes.
///
/// Walking sublayers rather than subviews is what makes SwiftUI-drawn content reachable, and it
/// gets the z-order right for free: a hosting view's `sublayers` holds its drawn layers and the
/// backing layers of any bridged UIKit views interleaved, back to front, exactly as they draw.
enum TargetNodeBuilder {

    /// Nodes for everything drawn directly inside `layer`, back to front.
    ///
    /// A sublayer that a `UIView` backs becomes a view node, so the ordinary view rules keep
    /// applying to it; anything else is SwiftUI's own drawing and becomes a layer node.
    static func nodes(
        forSublayersOf layer: CALayer,
        parent: TargetNode,
        isInsideHostingView: Bool
    ) -> [TargetNode] {
        (layer.sublayers ?? []).compactMap { sublayer in
            if let view = sublayer.delegate as? UIView {
                guard view.isSentinelDisplayable, !(view is SentinelOverlayView) else { return nil }
                return UIViewTargetNode(view: view, parent: parent, isInsideHostingView: isInsideHostingView)
            }
            guard sublayer.isSentinelDisplayable, let host = sublayer.sentinelHostView else { return nil }
            return CALayerTargetNode(layer: sublayer, hostView: host, parent: parent)
        }
    }

    /// The live element behind `node` — the view, or the layer for SwiftUI-drawn content.
    static func handle(of node: TargetNode) -> AnnotationTargetHandle? {
        switch node {
        case let viewNode as UIViewTargetNode:
            return viewNode.view
        case let layerNode as CALayerTargetNode:
            return layerNode.layer
        default:
            return nil
        }
    }
}

#endif
