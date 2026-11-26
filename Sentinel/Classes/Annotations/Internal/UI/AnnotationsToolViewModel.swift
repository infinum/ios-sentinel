//
//  AnnotationsToolViewModel.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import Combine
import Foundation

final class AnnotationsToolViewModel: ObservableObject {

    // MARK: - Internal properties

    @Published private(set) var annotations: [SentinelAnnotation] = []
    @Published private(set) var isExporting = false
    @Published var message: ExportMessage?

    let name: String
    let exporterIcon: String
    let exporterLabel: String

    // MARK: - Private properties

    private let store: AnnotationStore
    private let exporter: AnnotationExporter

    // MARK: - Lifecycle

    init(name: String, exporter: AnnotationExporter, store: AnnotationStore = .shared) {
        self.name = name
        self.exporter = exporter
        self.store = store
        exporterIcon = exporter.iconSystemName
        exporterLabel = exporter.label

        store.$annotations
            .receive(on: DispatchQueue.main)
            .assign(to: &$annotations)
    }

    // MARK: - Internal methods

    /// Arms capture and closes the whole Sentinel panel, so the user lands back on the live app
    /// with capture on. Closing only this screen would leave them looking at Sentinel's own tab
    /// bar with the overlay armed behind it.
    func arm() {
        store.isCaptureActive = true
        Sentinel.shared.dismissPanel()
    }

    func delete(at offsets: IndexSet) {
        offsets.map { annotations[$0].id }.forEach(store.remove(id:))
    }

    func clear() {
        store.clear()
    }

    /// Exports the notes that have not been sent yet, then marks them sent. Reports the
    /// exporter's own status message, or the failure it threw.
    func export() {
        let pending = store.annotations.filter { !$0.isSent }
        guard !pending.isEmpty else {
            message = ExportMessage(text: "No annotations to export")
            return
        }

        isExporting = true
        // The exporter is copied out rather than reached through `self`, so the task holds no
        // reference to this view model and cannot keep the screen alive past its dismissal.
        let exporter = self.exporter
        Task {
            do {
                let result = try await exporter.export(pending)
                // Marked sent only after the exporter returned: a note flagged as delivered
                // when the export threw would never be sent again.
                await self.finishExport(message: result, sent: pending.map(\.id))
            } catch {
                await self.finishExport(message: "Export failed: \(error.localizedDescription)", sent: [])
            }
        }
    }

    // MARK: - Private methods

    @MainActor
    private func finishExport(message: String, sent: [String]) {
        store.markSent(ids: sent)
        isExporting = false
        self.message = ExportMessage(text: message)
    }
}

/// An export status, carried as an identified value rather than a bare `String`.
///
/// Two identical statuses in a row — exporting the same batch twice, say — would otherwise be
/// indistinguishable to `onChange`, and the second one would never be shown.
struct ExportMessage: Equatable, Identifiable {

    let id = UUID()
    let text: String
}

#endif
