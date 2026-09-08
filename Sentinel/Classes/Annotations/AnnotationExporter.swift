//
//  AnnotationExporter.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import Foundation

/// Strategy for sending captured annotations somewhere.
///
/// Implement this to route notes to a server, a file or an issue tracker. The full
/// ``SentinelAnnotation`` values are passed in so an implementation controls its own
/// serialization; ``SentinelAnnotation/exportJSON(for:)`` produces the default payload.
///
/// Return a short status message to show the user. Throw to signal failure — the Annotations
/// screen reports it as `Export failed: ...`. Implementations stay UI free.
///
/// `Sendable` because ``export(_:)`` is awaited off the main thread: an exporter is handed to a
/// task and must therefore be safe to hand across one.
public protocol AnnotationExporter: Sendable {

    /// SF Symbol name for the export button's icon.
    var iconSystemName: String { get }

    /// The export button's label.
    var label: String { get }

    /// Sends `annotations` and returns a short status message.
    func export(_ annotations: [SentinelAnnotation]) async throws -> String
}

#endif
