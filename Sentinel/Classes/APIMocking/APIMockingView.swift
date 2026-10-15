//
//  APIMockingView.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI

struct APIMockingView: View {

    let title: String

    // The store is a singleton, so observing it directly survives `SentinelListView` rebuilding this view.
    @ObservedObject private var store = APIMockStore.shared
    @State private var searchText = ""
    @State private var editor: APIMockEditorRoute?
    @State private var expandedGroups: Set<String> = []

    var body: some View {
        List {
            Section(footer: Text(activeSummary)) {
                Toggle("Enabled", isOn: masterSwitch)
                    #if os(macOS)
                    .toggleStyle(.switch)
                    #endif
                    .accessibilityIdentifier(AccessibilityIdentifier.apiMockingMasterSwitch)
            }

            #if os(macOS)
            // Searchable's toolbar and sidebar placements belong to Sentinel's own window, so search lives inline.
            Section {
                HStack {
                    TextField("Search mocks", text: $searchText)
                    Button("New mock", action: createMock)
                        .accessibilityIdentifier(AccessibilityIdentifier.apiMockingNewButton)
                }
            }
            #endif

            Section(header: Text("Local mocks")) {
                if filteredLocalMocks.isEmpty {
                    Text(localMocksPlaceholder)
                        .font(.caption1Regular)
                        .foregroundColor(.secondary)
                }
                rows(for: filteredLocalMocks, isLocal: true)
            }

            if !store.appMocks.isEmpty {
                Section(header: Text("App mocks")) {
                    rows(for: filteredAppMocks, isLocal: false)
                }
            }
        }
        .pushedListTopMargin(isPushed: true)
        #if os(iOS)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search mocks"
        )
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: createMock) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New mock")
                .accessibilityIdentifier(AccessibilityIdentifier.apiMockingNewButton)
            }
        }
        #endif
        .navigationTitle(title)
        .sheet(item: $editor) { route in
            APIMockEditorView(
                route: route,
                store: store,
                dismiss: { editor = nil }
            )
        }
    }
}

// MARK: - Rows

private extension APIMockingView {

    func rows(for mocks: [APIMock], isLocal: Bool) -> some View {
        ForEach(APIMockListEntry.entries(for: mocks)) { entry in
            switch entry {
            case .mock(let mock):
                row(for: mock, isLocal: isLocal)
            case .group(let name, let mocks):
                DisclosureGroup(isExpanded: isExpanded(group: name, isLocal: isLocal)) {
                    ForEach(mocks) { mock in
                        row(for: mock, isLocal: isLocal)
                    }
                } label: {
                    groupLabel(name: name, mocks: mocks)
                }
            }
        }
    }

    func groupLabel(name: String, mocks: [APIMock]) -> some View {
        let enabledCount = mocks.filter(store.isEnabled).count
        return VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.body1Bold)
            Text("\(mocks.count) \(mocks.count == 1 ? "mock" : "mocks") · \(enabledCount) on")
                .font(.caption1Regular)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier(AccessibilityIdentifier.apiMockingGroup(name))
    }

    /// Groups start collapsed, and open while a search matches mocks in them.
    func isExpanded(group: String, isLocal: Bool) -> Binding<Bool> {
        // The same name can be used in both sections, which expand on their own.
        let key = "\(isLocal ? "local" : "app").\(group)"
        return Binding(
            get: { !searchText.isEmpty || expandedGroups.contains(key) },
            set: { isExpanded in
                if isExpanded {
                    expandedGroups.insert(key)
                } else {
                    expandedGroups.remove(key)
                }
            }
        )
    }

    func row(for mock: APIMock, isLocal: Bool) -> some View {
        APIMockRow(
            mock: mock,
            isOn: Binding(
                get: { store.isEnabled(mock) },
                set: { store.setEnabled($0, for: mock) }
            ),
            didSelect: { open(mock, isLocal: isLocal) }
        )
        .swipeActions {
            if isLocal {
                Button(role: .destructive) {
                    store.delete(mock)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            Button {
                duplicate(mock)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
        }
        .contextMenu {
            Button {
                duplicate(mock)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            if isLocal {
                Button(role: .destructive) {
                    store.delete(mock)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - Actions

private extension APIMockingView {

    func createMock() {
        editor = APIMockEditorRoute(mode: .create, draft: APIMockDraft())
    }

    func open(_ mock: APIMock, isLocal: Bool) {
        editor = APIMockEditorRoute(
            mode: isLocal ? .editLocal : .viewApp,
            draft: APIMockDraft(mock: mock)
        )
    }

    func duplicate(_ mock: APIMock) {
        editor = APIMockEditorRoute(mode: .create, draft: APIMockDraft(copying: mock))
    }
}

// MARK: - Helpers

private extension APIMockingView {

    var masterSwitch: Binding<Bool> {
        Binding(
            get: { store.isMockingEnabled },
            set: { store.setMockingEnabled($0) }
        )
    }

    var activeSummary: String {
        guard store.isMockingEnabled else { return "Mocking is off. Every request goes to the network." }
        switch store.activeMocks.count {
        case 0: return "No mock is switched on."
        case 1: return "1 mock answers requests."
        case let count: return "\(count) mocks answer requests."
        }
    }

    var localMocksPlaceholder: String {
        guard searchText.isEmpty else { return "No local mock matches the search." }
        #if os(macOS)
        return "Create a mock with New mock, or duplicate an app mock."
        #else
        return "Create a mock with +, or duplicate an app mock."
        #endif
    }

    var filteredLocalMocks: [APIMock] {
        store.localMocks.filter(matchesSearch)
    }

    var filteredAppMocks: [APIMock] {
        store.appMocks.filter(matchesSearch)
    }

    func matchesSearch(_ mock: APIMock) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return true }
        return [mock.name, mock.description, mock.group ?? "", mock.url.pattern]
            .contains { $0.lowercased().contains(query) }
    }
}
