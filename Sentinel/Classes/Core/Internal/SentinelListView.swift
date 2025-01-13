//
//  SentinelListView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 08.11.2024..
//

import SwiftUI

struct SentinelListView: View {

    @State private var selectedItem: String?
    let title: String
    let items: [ToolTableSection]

    var body: some View {
        NavigationView {
            List(items, id: \.id) { section in
                Section {
                    if let title = section.title {
                        Text(title)
                    }

                    ForEach(section.items) { item in
                        switch item {
                        case .navigation(let item):
                            NavigationLink(destination: { AnyView(item.didSelect()) }) {
                                NavigationToolTableView(item: item)
                            }
                        case .toggle(let item):
                            OptionSwitchView(item: item)
                        case .customInfo(let item):
                            NavigationLink(destination: Text("Something")) {
                                TitleValueView(item: item)
                            }
                        case .performance(let item):
                            PerformanceToolView(viewModel: .init(item: item))
                        case .custom(let item):
                            AnyView(item.content)
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}
