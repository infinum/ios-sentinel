//
//  AnnotationsTool.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import SwiftUI

/// Tool which attaches free-text notes to elements on the running app and exports them.
///
/// Ships with ``ClipboardAnnotationExporter``. Pass an exporter to change the destination, for
/// example `AnnotationsTool(exporter: ClaudeRoutineExporter(token: { token }, fireUrl: url))`.
///
/// Creating the tool starts the capture overlay's observer. The overlay itself is only added to
/// the screen once capture is armed or a note exists, so an app that never annotates anything
/// pays nothing for having the tool installed.
public struct AnnotationsTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Private properties

    private let exporter: AnnotationExporter

    // MARK: - Lifecycle

    /// - Parameters:
    ///     - name: Name of the tool.
    ///     - exporter: Where the captured notes are sent. Defaults to the system clipboard.
    public init(name: String = "Annotations", exporter: AnnotationExporter = ClipboardAnnotationExporter()) {
        self.name = name
        self.exporter = exporter
        AnnotationOverlayCoordinator.shared.start()
    }
}

// MARK: - UI

public extension AnnotationsTool {

    var content: any View {
        AnnotationsToolView(viewModel: AnnotationsToolViewModel(name: name, exporter: exporter))
    }
}

#endif
