//
//  TargetResolver.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// A resolved selection: the toolkit-independent description, the live view used to recompute
/// bounds while the note is on screen, and the tree root.
///
/// `root` is held on purpose. Nodes link to their parent weakly, so dropping the root would
/// break the ancestor chain that ``TargetSelection/stepUp(from:)`` and
/// ``TargetSelection/path(of:)`` walk.
struct ResolvedTarget {

    let root: TargetNode
    let node: TargetNode
    let view: UIView

    var toolkit: AnnotationToolkit { node.toolkit }
}

protocol TargetResolver {

    /// The annotatable target at `point` in screen coordinates, or `nil`.
    func resolve(root: UIView, at point: CGPoint) -> ResolvedTarget?

    /// The live element `annotation` should now point at after its screen was recreated.
    func rebind(_ annotation: SentinelAnnotation, root: UIView) -> ResolvedTarget?
}

final class UIViewTargetResolver: TargetResolver {

    // MARK: - Internal methods

    func resolve(root: UIView, at point: CGPoint) -> ResolvedTarget? {
        let tree = UIViewTargetNode(view: root, parent: nil)
        guard let deepest = TargetSelection.deepest(in: tree, at: point) else { return nil }
        let selected = TargetSelection.nearestAnnotatable(from: deepest) ?? deepest
        guard let node = selected as? UIViewTargetNode else { return nil }
        return ResolvedTarget(root: tree, node: node, view: node.view)
    }

    /// Re-points `annotation` at the element now drawn where it was captured.
    ///
    /// Accepts only a same-type match that also matches the captured accessibility identifier,
    /// or — when the element has none — the captured text. Fields that did not resolve on either
    /// side stay permissive, so a missing value never orphans a note.
    func rebind(_ annotation: SentinelAnnotation, root: UIView) -> ResolvedTarget? {
        guard let candidate = resolve(root: root, at: annotation.rebindPoint) else { return nil }
        let node = candidate.node
        guard node.type == annotation.targetType else { return nil }
        if let identifier = annotation.accessibilityIdentifier {
            guard node.accessibilityIdentifier == identifier else { return nil }
        } else if let text = annotation.text {
            guard node.text == text else { return nil }
        }
        return candidate
    }
}

#endif
