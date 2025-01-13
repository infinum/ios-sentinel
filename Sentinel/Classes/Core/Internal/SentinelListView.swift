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
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(items, id: \.id) { section in
                        VStack(spacing: 5) {
                            if let title = section.title {
                                Text(title)
                                    .padding(.bottom, 10)
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
                                    TitleValueView(item: item)
                                case .performance(let item):
                                    PerformanceToolView(viewModel: .init(item: item))
                                case .custom(let item):
                                    AnyView(item.content)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationTitle(title)
    }
}
