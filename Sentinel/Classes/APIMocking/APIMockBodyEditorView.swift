//
//  APIMockBodyEditorView.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI

#if os(iOS)

/// The response body on a screen of its own, so a long body gets the whole screen to be read and edited.
struct APIMockBodyEditorView: View {

    @Binding var draft: APIMockDraft
    let isReadOnly: Bool

    @FocusState private var isEditing: Bool

    var body: some View {
        VStack(spacing: 0) {
            if isReadOnly {
                ScrollView {
                    Text(draft.body.isEmpty ? "No body" : draft.body)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                }
            } else {
                TextEditor(text: $draft.body)
                    .font(.system(.caption, design: .monospaced))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isEditing)
                    .padding(.horizontal, 12)
                    .accessibilityIdentifier(AccessibilityIdentifier.apiMockingBodyEditor)
            }

            Divider()

            HStack(spacing: 16) {
                Text(draft.jsonStatus.message)
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if isReadOnly {
                    Button("Copy") {
                        UIPasteboard.general.string = draft.body
                    }
                } else {
                    Button("Format JSON") {
                        draft.formatBody()
                    }
                    .disabled(draft.jsonStatus != .valid)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle("Body")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarMaterialBackground()
        .doneEditingButton(isEditing: isEditing) { isEditing = false }
    }
}

#endif
