//
//  ClipboardAnnotationExporter.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// Default exporter. Copies the export JSON to the system clipboard.
public struct ClipboardAnnotationExporter: AnnotationExporter {

    // MARK: - Public properties

    public let iconSystemName = "doc.on.doc"

    public let label = "Copy to clipboard"

    // MARK: - Lifecycle

    public init() {}

    // MARK: - Public methods

    public func export(_ annotations: [SentinelAnnotation]) async throws -> String {
        let json = try SentinelAnnotation.exportJSON(for: annotations)
        // `export` is awaited off the main thread, and `UIPasteboard` is not documented as
        // thread safe, so the write is hopped over explicitly.
        await MainActor.run { UIPasteboard.general.string = json }
        return "Copied \(annotations.count) annotations"
    }
}

#endif
