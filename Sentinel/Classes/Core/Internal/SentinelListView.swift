//
//  SentinelListView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 08.11.2024..
//

import SwiftUI

struct SentinelListView: View {
    let title: String
    let items: [ToolTableSection]

    var body: some View {
    #if os(macOS)
        NavigationView {
            ContentView(title: title, items: items)
                .frame(width: 400)
        }
    #else
        ContentView(title: title, items: items)
    #endif
    }
}

private struct ContentView: View {

    @State private var selectedItem: String?
    let title: String
    let items: [ToolTableSection]

    var body: some View {
        List(items, id: \.id) { section in
            Section  {
                if let title = section.title {
                    Text(title)
                        .font(.headline)
                }

                ForEach(section.items) { item in
                    switch item {
                    case .navigation(let item):
                        NavigationLink(
                            destination: AnyView(item.didSelect()),
                            tag: item.id,
                            selection: $selectedItem,
                            label: { NavigationToolTableView(item: item) }
                        )
                    case .toggle(let item):
                        OptionSwitchView(item: item)
                    case .customInfo(let item):
                        TitleValueView(item: item)
                    case .performance(let item):
                        PerformanceToolView(viewModel: .init(item: item))
                    case .custom(let item):
                        AnyView(item.content)
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}
