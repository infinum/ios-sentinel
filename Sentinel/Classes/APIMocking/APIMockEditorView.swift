//
//  APIMockEditorView.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI

/// What the mock editor sheet opens with.
struct APIMockEditorRoute: Identifiable {

    enum Mode {
        /// A new local mock, blank or copied from another mock.
        case create
        case editLocal
        /// A mock the app ships with, which can be read and duplicated but not changed.
        case viewApp
    }

    let id = UUID()
    let mode: Mode
    let draft: APIMockDraft
}

struct APIMockEditorView: View {

    private enum Field: Hashable {
        case name
        case description
        case group
        case pattern
        case statusCode
    }

    @ObservedObject var store: APIMockStore
    let dismiss: () -> Void

    @FocusState private var focusedField: Field?
    @State private var mode: APIMockEditorRoute.Mode
    @State private var draft: APIMockDraft
    @State private var isConfirmingDelete = false
    @State private var isSharing = false
    @State private var shareItems: [Any] = []

    init(
        route: APIMockEditorRoute,
        store: APIMockStore,
        dismiss: @escaping () -> Void
    ) {
        self.store = store
        self.dismiss = dismiss
        _mode = State(initialValue: route.mode)
        _draft = State(initialValue: route.draft)
    }

    var body: some View {
        #if os(iOS)
        NavigationView {
            form
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(isReadOnly ? "Done" : "Cancel", action: dismiss)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if !isReadOnly {
                            saveButton
                        }
                    }
                }
                .toolbar {
                    // The status code's number pad has no return key, so every field gets a way out. Above
                    // the keyboard, as the navigation bar already holds Save and the form has no bottom buttons.
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
        }
        // Keeps iPad from showing the form in a split view.
        .navigationViewStyle(.stack)
        #else
        VStack(spacing: 0) {
            Text(title)
                .font(.subtitle1Bold)
                .padding(.top, 16)
            form
                .formStyle(.grouped)
            HStack {
                Spacer()
                Button(isReadOnly ? "Done" : "Cancel", action: dismiss)
                    .keyboardShortcut(.cancelAction)
                if !isReadOnly {
                    saveButton
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding(16)
        }
        .frame(minWidth: 520, minHeight: 600)
        #endif
    }
}

// MARK: - Form

private extension APIMockEditorView {

    var form: some View {
        Form {
            Section(header: Text("Mock")) {
                if isReadOnly {
                    // Text rather than disabled fields, so long values wrap instead of being cut off.
                    Text(draft.name)
                    if !draft.description.isEmpty {
                        Text(draft.description)
                            .foregroundColor(.secondary)
                    }
                    if let group = draft.trimmedGroup {
                        HStack {
                            Text("Group")
                            Spacer()
                            Text(group)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    TextField("Name", text: $draft.name)
                        .focused($focusedField, equals: .name)
                        .accessibilityIdentifier(AccessibilityIdentifier.apiMockingNameField)
                    TextField("Description", text: $draft.description)
                        .focused($focusedField, equals: .description)
                    TextField("Group (optional)", text: $draft.group)
                        .focused($focusedField, equals: .group)
                        .accessibilityIdentifier(AccessibilityIdentifier.apiMockingGroupField)
                }
            }

            Section(header: Text("Request"), footer: Text(patternHint)) {
                Picker("Method", selection: $draft.method) {
                    Text("Any").tag(APIMock.HTTPMethod?.none)
                    ForEach(APIMock.HTTPMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(Optional(method))
                    }
                }
                .pickerStyle(.menu)

                HStack {
                    if isReadOnly {
                        Text(draft.pattern)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        TextField(patternPlaceholder, text: $draft.pattern)
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            #endif
                            .focused($focusedField, equals: .pattern)
                            .accessibilityIdentifier(AccessibilityIdentifier.apiMockingPatternField)
                    }
                    Picker("Match", selection: $draft.matchKind) {
                        ForEach(APIMock.URLPattern.Kind.allCases, id: \.self) { kind in
                            Text(kind.title).tag(kind)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .fixedSize()
                }

                if let error = draft.patternError {
                    Text(error)
                        .font(.caption1Regular)
                        .foregroundColor(.red)
                }
            }
            .disabled(isReadOnly)

            Section(header: Text("Response")) {
                Picker("Response", selection: $draft.responseKind) {
                    Text("HTTP response").tag(APIMockDraft.ResponseKind.http)
                    Text("Network error").tag(APIMockDraft.ResponseKind.networkError)
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                switch draft.responseKind {
                case .http:
                    HStack {
                        Text("Status code")
                        Spacer()
                        TextField("200", text: $draft.statusCode)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 80)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            .focused($focusedField, equals: .statusCode)
                    }
                    if draft.statusCodeValue == nil {
                        Text("Enter a status code from 100 to 599.")
                            .font(.caption1Regular)
                            .foregroundColor(.red)
                    }
                case .networkError:
                    Picker("Error", selection: $draft.networkError) {
                        ForEach(APIMock.NetworkError.allCases, id: \.self) { error in
                            Text(error.title).tag(error)
                        }
                    }
                    .pickerStyle(.menu)
                }

                if isReadOnly {
                    delayRow
                } else {
                    Stepper(value: $draft.delay, in: 0...30, step: 0.5) {
                        delayRow
                    }
                }
            }
            .disabled(isReadOnly)

            if draft.responseKind == .http {
                bodySection
            }

            actionsSection
        }
        .alert(isPresented: $isConfirmingDelete) {
            Alert(
                title: Text("Delete “\(draft.trimmedName)”?"),
                message: Text("This can't be undone."),
                primaryButton: .destructive(Text("Delete"), action: delete),
                secondaryButton: .cancel()
            )
        }
        .share(showShare: $isSharing, items: shareItems, didFinish: {})
    }

    var bodySection: some View {
        Section(header: Text("Body"), footer: Text(draft.jsonStatus.message)) {
            #if os(iOS)
            // A preview that opens the body on a screen of its own, as a long body would crowd the form.
            NavigationLink {
                APIMockBodyEditorView(draft: $draft, isReadOnly: isReadOnly)
            } label: {
                bodyPreview
            }
            .accessibilityIdentifier(AccessibilityIdentifier.apiMockingBodyRow)
            #else
            if isReadOnly {
                Text(draft.body.isEmpty ? "No body" : draft.body)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button("Copy body", action: copyBody)
            } else {
                TextEditor(text: $draft.body)
                    .font(.system(.caption, design: .monospaced))
                    .frame(minHeight: 240)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier(AccessibilityIdentifier.apiMockingBodyEditor)
                Button("Format JSON") {
                    draft.formatBody()
                }
                .disabled(draft.jsonStatus != .valid)
            }
            #endif
        }
    }

    #if os(iOS)
    var bodyPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            if draft.body.isEmpty {
                Text(isReadOnly ? "No body" : "Add a body")
                    .foregroundColor(.secondary)
            } else {
                Text(draft.bodyPreview)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(APIMockDraft.bodyPreviewLineCount)
                Text(draft.bodySummary)
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    #endif

    @ViewBuilder
    var actionsSection: some View {
        switch mode {
        case .create:
            EmptyView()
        case .editLocal:
            Section {
                Button("Share", action: share)
                Button("Delete mock", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
        case .viewApp:
            Section(footer: Text("Mocks the app ships with can't be changed. Duplicate one to edit a copy.")) {
                Button("Duplicate as local mock") {
                    draft = APIMockDraft(copying: draft.makeMock())
                    mode = .create
                }
            }
        }
    }

    var delayRow: some View {
        HStack {
            Text("Delay")
            Spacer()
            Text(draft.delay.formattedSeconds)
                .foregroundColor(.secondary)
        }
    }

    var saveButton: some View {
        Button("Save") {
            store.save(draft.makeMock())
            dismiss()
        }
        .disabled(!draft.canSave)
        .accessibilityIdentifier(AccessibilityIdentifier.apiMockingSaveButton)
    }
}

// MARK: - Actions

private extension APIMockEditorView {

    func delete() {
        store.delete(draft.makeMock())
        dismiss()
    }

    #if os(macOS)
    func copyBody() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(draft.body, forType: .string)
    }
    #endif

    func share() {
        shareItems = APIMockShare(draft: draft).makeItems()
        isSharing = true
    }
}

// MARK: - Helpers

private extension APIMockEditorView {

    var isReadOnly: Bool {
        mode == .viewApp
    }

    var title: String {
        switch mode {
        case .create: return "New mock"
        case .editLocal: return "Edit mock"
        case .viewApp: return draft.trimmedName
        }
    }

    var patternPlaceholder: String {
        switch draft.matchKind {
        case .wildcard: return "/api/v1/users/*"
        case .regex: return "/api/v1/users/\\d+$"
        }
    }

    var patternHint: String {
        switch draft.matchKind {
        case .wildcard:
            return "Matches URLs ending with the pattern; * matches anything. The query is ignored unless the pattern has a ?."
        case .regex:
            return "A case-insensitive regular expression that has to match somewhere in the full URL."
        }
    }
}
