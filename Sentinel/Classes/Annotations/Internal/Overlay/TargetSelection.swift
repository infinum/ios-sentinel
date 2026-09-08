//
//  TargetSelection.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import CoreGraphics
import Foundation

/// The rules that turn a tap into a selection.
enum TargetSelection {

    /// The innermost node containing `point`, or `nil` when the point misses `root`.
    /// Children are tested last-first because the last child draws on top.
    static func deepest(in root: TargetNode, at point: CGPoint) -> TargetNode? {
        guard root.screenFrame.contains(point) else { return nil }
        for child in root.children.reversed() {
            if let hit = deepest(in: child, at: point) {
                return hit
            }
        }
        return root
    }

    /// The deepest annotatable node at or above `node`, or `nil` when none qualifies.
    static func nearestAnnotatable(from node: TargetNode) -> TargetNode? {
        var current: TargetNode? = node
        while let candidate = current {
            if candidate.isAnnotatable {
                return candidate
            }
            current = candidate.parent
        }
        return nil
    }

    /// The selection broadened one annotatable node toward the root, or `nil` when `node` is
    /// already the outermost one — the caller then wraps back to the deepest target.
    static func stepUp(from node: TargetNode) -> TargetNode? {
        var current = node.parent
        while let candidate = current {
            if candidate.isBroadenable {
                return candidate
            }
            current = candidate.parent
        }
        return nil
    }

    /// The chain of annotatable types from the outermost ancestor down to `node`.
    static func path(of node: TargetNode) -> String {
        var types: [String] = []
        var current: TargetNode? = node
        while let candidate = current {
            if candidate.isAnnotatable {
                types.append(candidate.type)
            }
            current = candidate.parent
        }
        return types.reversed().joined(separator: ">")
    }

    /// The root of the tree `node` belongs to.
    ///
    /// ``ordinal(of:in:)`` locates its target by node identity, so it must be counted against
    /// the very tree the target came from — a freshly built one holds different node objects for
    /// the same views, and the target would never be found in it.
    static func root(of node: TargetNode) -> TargetNode {
        var current = node
        while let parent = current.parent {
            current = parent
        }
        return current
    }

    /// Position of `node` among same-type nodes under `root`, as `(ordinal, count)`, ordered top
    /// to bottom then left to right. `(1, count)` when `node` cannot be located among the
    /// matches.
    static func ordinal(of node: TargetNode, in root: TargetNode) -> (ordinal: Int, count: Int) {
        var matches: [TargetNode] = []
        collect(type: node.type, from: root, into: &matches)
        matches.sort { lhs, rhs in
            lhs.screenFrame.minY == rhs.screenFrame.minY
                ? lhs.screenFrame.minX < rhs.screenFrame.minX
                : lhs.screenFrame.minY < rhs.screenFrame.minY
        }

        guard let index = matches.firstIndex(where: { $0 === node }) else {
            return (1, max(matches.count, 1))
        }
        return (index + 1, matches.count)
    }

    // MARK: - Private methods

    private static func collect(type: String, from node: TargetNode, into matches: inout [TargetNode]) {
        if node.type == type && !node.screenFrame.isEmpty {
            matches.append(node)
        }
        node.children.forEach { collect(type: type, from: $0, into: &matches) }
    }
}

#endif
