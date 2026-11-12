//
//  SentinelListView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 08.11.2024..
//

import SwiftUI
import Combine

struct SentinelListView: View {
    let title: String
    let items: [ToolTableSection]
    /// `true` for the list at the root of a tab, `false` for a list pushed from it.
    var isTabRoot = false

    @State private var selectedItem: String?

    var body: some View {
    #if os(macOS)
        NavigationSplitView(
            sidebar: {
                ContentView(
                    title: title,
                    sections: items,
                    isTabRoot: isTabRoot,
                    selectedItem: $selectedItem
                )
                    .frame(minWidth: 400) // Expands the content in width so it's visible
            },
            detail: {
                if let item = navigationItem(withID: selectedItem) {
                    AnyView(item.didSelect($selectedItem))
                }
            }
        )
    #else
        ContentView(
            title: title,
            sections: items,
            isTabRoot: isTabRoot,
            selectedItem: $selectedItem
        )
    #endif
    }
}

#if os(macOS)
private extension SentinelListView {

    /// Looks the item up in the unfiltered sections, so the open tool stays open while searching.
    func navigationItem(withID id: String?) -> NavigationToolItem? {
        items
            .flatMap(\.items)
            .lazy
            .compactMap { item -> NavigationToolItem? in
                guard case .navigation(let navigationItem) = item else { return nil }
                return navigationItem
            }
            .first { $0.id == id }
    }
}
#endif

private struct ContentView: View {

    let title: String
    let isTabRoot: Bool
    @Binding var selectedItem: String?

    @ObservedObject var viewModel: SentinelListViewModel

    var body: some View {
        List(viewModel.sections, id: \.id, selection: listSelection) { currentSection in
            Section {
                if let title = currentSection.title {
                    Text(title)
                        .font(.title1Bold)
                }

                ForEach(currentSection.items) { item in
                    switch item {
                    case .navigation(let item):
                        #if os(macOS)
                        // The split view's detail column shows the selected row's tool.
                        NavigationToolTableView(item: item)
                            .tag(item.id)
                            .accessibilityIdentifier(AccessibilityIdentifier.row(item.title))
                        #else
                        // Set on the destination as well, so every pushed tool's content gets it, custom tools too.
                        NavigationLink(
                            destination: AnyView(item.didSelect()).navigationBarMaterialBackground(),
                            tag: item.id,
                            selection: $selectedItem,
                            label: { NavigationToolTableView(item: item) }
                        )
                        .accessibilityIdentifier(AccessibilityIdentifier.row(item.title))
                        #endif
                    case .toggle(let item):
                        PreferencesView(item: item)
                    case .customInfo(let item):
                        TitleValueView(item: item)
                    case .performance(let item):
                        PerformanceToolView(viewModel: PerformanceInfoViewModel(item: item))
                    case .custom(let item):
                        AnyView(item.content)
                    }
                }
            }
        }
        .pushedListTopMargin(isPushed: !isTabRoot)
        .navigationBarMaterialBackground()
        .sentinelSearchable(text: $viewModel.searchText, prompt: "Search for an item")
        .navigationTitle(title)
    }
}

private extension ContentView {

    /// On iOS rows push through `NavigationLink`, so the list itself doesn't track a selection.
    var listSelection: Binding<String?>? {
        #if os(macOS)
        $selectedItem
        #else
        nil
        #endif
    }
}

extension ContentView {

    init(
        title: String,
        sections: [ToolTableSection],
        isTabRoot: Bool,
        selectedItem: Binding<String?>
    ) {
        self.title = title
        self.isTabRoot = isTabRoot
        _selectedItem = selectedItem
        viewModel = SentinelListViewModel(sections: sections)
    }
}
