//
//  AnnotationNoteSheet.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import SwiftUI

/// The note input sheet, presented from the capture overlay's own window.
struct AnnotationNoteSheet: View {

    // MARK: - Private properties

    private let targetType: String
    private let canDelete: Bool
    private let onSave: (String) -> Void
    private let onDelete: (() -> Void)?
    private let onCancel: () -> Void

    @State private var note: String

    // MARK: - Lifecycle

    init(
        targetType: String,
        initial: String,
        canDelete: Bool,
        onSave: @escaping (String) -> Void,
        onDelete: (() -> Void)?,
        onCancel: @escaping () -> Void
    ) {
        self.targetType = targetType
        self.canDelete = canDelete
        self.onSave = onSave
        self.onDelete = onDelete
        self.onCancel = onCancel
        _note = State(initialValue: initial)
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Describe the issue here")
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)

                TextEditor(text: $note)
                    .font(.body1Regular)
                    .frame(minHeight: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                    )

                if canDelete {
                    Button(action: { onDelete?() }) {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle(canDelete ? "Edit note for \(targetType)" : "Note for \(targetType)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onCancel) {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: save) {
                        Text("Save")
                    }
                    .disabled(!canDelete && trimmedNote.isEmpty)
                }
            }
        }
    }

    // MARK: - Private methods

    private var trimmedNote: String {
        note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Clearing an existing note deletes it, which is how the library this feature is ported
    /// from behaves: an empty note carries nothing an agent could act on.
    private func save() {
        guard !trimmedNote.isEmpty else {
            onDelete?()
            return
        }
        onSave(trimmedNote)
    }
}

#endif
