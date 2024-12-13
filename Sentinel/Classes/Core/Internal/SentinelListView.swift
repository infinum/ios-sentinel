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
        List(items, id: \.title) { section in
            Section {
                if let title = section.title {
                    Text(title)
                }

                ForEach(section.items) { item in
                    switch item {
                    case .navigation(let item):
                        NavigationLink {
                            AnyView(item.didSelect())
                        } label: {
                            NavigationToolTableView(item: item)
                        }
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
