//
//  AnnotationsToolView.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import SwiftUI

struct AnnotationsToolView: View {

    // MARK: - Internal properties

    @ObservedObject var viewModel: AnnotationsToolViewModel

    // MARK: - Private properties

    @State private var activeAlert: ActiveAlert?

    // MARK: - Body

    var body: some View {
        List {
            if viewModel.annotations.isEmpty {
                emptyStateSection
            } else {
                actionsSection
                notesSection
            }
        }
        .navigationTitle(viewModel.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { activeAlert = .clear }) {
                    Image(systemName: "trash")
                }
                .disabled(viewModel.annotations.isEmpty)
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .clear:
                return Alert(
                    title: Text("Clear all annotations?"),
                    message: Text(
                        "This will remove all \(viewModel.annotations.count) annotations. "
                            + "Notes are kept in memory only, so this cannot be undone."
                    ),
                    primaryButton: .destructive(Text("Clear")) { viewModel.clear() },
                    secondaryButton: .cancel()
                )
            case .message(let text):
                return Alert(
                    title: Text(text),
                    dismissButton: .default(Text("OK")) { viewModel.message = nil }
                )
            }
        }
        .onChange(of: viewModel.message) { message in
            guard let message = message else { return }
            activeAlert = .message(message.text)
        }
    }
}

// MARK: - Sections

private extension AnnotationsToolView {

    var emptyStateSection: some View {
        Section {
            Button(action: viewModel.arm) {
                Text("Enable annotations")
                    .font(.subtitle1Bold)
            }

            Text("Tap an element on the current screen to attach a note. Sentinel closes so the live app is visible.")
                .font(.caption1Regular)
                .foregroundColor(.secondary)
        }
    }

    var actionsSection: some View {
        Section {
            Button(action: viewModel.arm) {
                Text("Start annotating")
                    .font(.subtitle1Bold)
            }

            Button(action: viewModel.export) {
                HStack(spacing: 8) {
                    if viewModel.isExporting {
                        ProgressView()
                    } else {
                        Image(systemName: viewModel.exporterIcon)
                    }

                    Text(viewModel.exporterLabel)
                }
            }
            .disabled(viewModel.isExporting)
        }
    }

    var notesSection: some View {
        Section(header: Text("Notes").font(.body1Bold)) {
            ForEach(Array(viewModel.annotations.enumerated()), id: \.element.id) { index, annotation in
                AnnotationRowView(number: index + 1, annotation: annotation)
            }
            .onDelete(perform: viewModel.delete(at:))
        }
    }
}

// MARK: - Row

private struct AnnotationRowView: View {

    let number: Int
    let annotation: SentinelAnnotation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("#\(number)")
                    .font(.body1Bold)
                    .foregroundColor(.secondary)

                Text(annotation.note)
                    .font(.body1Regular)

                Spacer()

                if annotation.isSent {
                    Text("Sent")
                        .font(.caption1Regular)
                        .foregroundColor(.secondary)
                }
            }

            Text(annotation.targetType)
                .font(.caption1Regular)
                .foregroundColor(.secondary)

            if let detail = detail {
                Text(detail)
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)
            }
        }
        .opacity(annotation.isSent ? 0.5 : 1)
    }

    /// The strongest locator the note resolved, which is what makes a row identifiable at a
    /// glance and what an agent will search for.
    private var detail: String? {
        annotation.accessibilityIdentifier ?? annotation.swiftUIType ?? annotation.viewController
    }
}

// MARK: - Alerts

private enum ActiveAlert: Identifiable {

    case clear
    case message(String)

    var id: String {
        switch self {
        case .clear: "clear"
        case .message(let text): "message-\(text)"
        }
    }
}

#endif
