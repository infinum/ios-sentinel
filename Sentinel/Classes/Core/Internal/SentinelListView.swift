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

    var body: some View {
    #if os(macOS)
        NavigationView {
            ContentView(title: title, sections: items)
                .frame(minWidth: 400) // Expands the content in width so it's visible
        }
    #else
        ContentView(title: title, sections: items)
    #endif
    }
}

private struct ContentView: View {

    @State private var selectedItem: String?
    let title: String

    @ObservedObject var viewModel: SentinelListViewModel

    var body: some View {
        List(viewModel.sections, id: \.id) { currentSection in
            Section {
                if let title = currentSection.title {
                    Text(title)
                        .font(.title1Bold)
                }

                ForEach(currentSection.items) { item in
                    switch item {
                    case .navigation(let item):
                        let destination = {
                            #if os(macOS)
                            AnyView(item.didSelect($selectedItem))
                            #else
                            AnyView(item.didSelect())
                            #endif
                        }
                        NavigationLink(
                            destination: destination(),
                            tag: item.id,
                            selection: $selectedItem,
                            label: { NavigationToolTableView(item: item) }
                        )
                    case .toggle(let item):
                        OptionToggleView(item: item)
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
        .searchableIfAvailable(text: $viewModel.searchText, prompt: "Search for an item")
        .navigationTitle(title)
    }
}
extension ContentView {

    init(title: String, sections: [ToolTableSection]) {
        self.title = title
        viewModel = .init(sections: sections)
    }
}
