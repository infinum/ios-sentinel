//
//  CALayerTargetNode.swift
//  Sentinel
//
//  Created by Sentinel on 08/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// Adapts one SwiftUI drawing layer to ``TargetNode``.
///
/// SwiftUI draws `Text`, `Image`, shapes and the rest itself and creates no backing view for
/// them, so a tap inside a hosting view has no subview to resolve to. It does give each of them a
/// `CALayer`, and that layer carries exact geometry — which is enough to select precisely what
/// the user pointed at.
///
/// What a layer cannot give is a name: no accessibility identifier, no SwiftUI type, and no text,
/// because a drawn layer's contents are already rasterised by the time they are here. A note on
/// SwiftUI-drawn content is therefore located by kind, position and ordinal, plus the app's own
/// view type from the enclosing hosting view. Everything read here — `sublayers`, `frame`,
/// `contents` — is ordinary public `CALayer` API, so there is nothing version-fragile about it.
final class CALayerTargetNode: TargetNode {

    // MARK: - Internal properties

    let layer: CALayer

    let type: String

    /// A layer carries no accessibility identifier, and reporting `CALayer.name` as one would
    /// claim an identity the developer never gave it.
    let accessibilityIdentifier: String? = nil

    let accessibilityLabel: String? = nil

    /// Only a `CATextLayer` keeps its string; SwiftUI's own drawing layers do not, so this is
    /// almost always `nil`.
    let text: String?

    let toolkit: AnnotationToolkit = .swiftUI

    var screenFrame: CGRect { layer.sentinelScreenFrame }

    var parent: TargetNode? { parentNode }

    /// Inherited from the enclosing hosting view: the app's own SwiftUI view type is the one
    /// locator a note on drawn content can carry, and it tells an agent which file to open.
    lazy var swiftUIType: String? = SwiftUIIdentity.rootTypeName(for: hostView)

    lazy var children: [TargetNode] = TargetNodeBuilder.nodes(
        forSublayersOf: layer,
        parent: self,
        isInsideHostingView: true
    )

    /// A layer worth selecting is one that draws: text, an image, a filled shape or a colour.
    /// A layer that only groups others is not a target itself, but broadening may stop at it.
    let isAnnotatable: Bool

    let isBroadenable = true

    // MARK: - Private properties

    private weak var parentNode: TargetNode?

    private let hostView: UIView

    // MARK: - Lifecycle

    init(layer: CALayer, hostView: UIView, parent: TargetNode?) {
        self.layer = layer
        self.hostView = hostView
        parentNode = parent

        type = SwiftUIIdentity.simpleTypeName(of: layer)
        text = (layer as? CATextLayer)?.string as? String
        isAnnotatable = Self.draws(layer)
    }

    // MARK: - Private methods

    private static func draws(_ layer: CALayer) -> Bool {
        if layer.contents != nil { return true }
        if let shape = layer as? CAShapeLayer, shape.path != nil { return true }
        if let text = layer as? CATextLayer, text.string != nil { return true }
        if layer is CAGradientLayer { return true }
        return layer.backgroundColor != nil
    }
}

#endif
