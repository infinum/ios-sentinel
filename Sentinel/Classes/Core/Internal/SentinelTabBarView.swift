//
//  SentinelTabBarView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 08.11.2024..
//

import SwiftUI

enum Tab {
    case device
    case application
    case tools
    case preferences
    case performance
}

struct SentinelTabBarView: View {

    @State var selectedTab: Tab = .tools
    let tabs: [SentinelTabItem]

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabs, id: \.barItemTitle) { tab in
                SentinelListView(title: tab.barItemTitle, items: tab.sections)
                    .tabItem { TabBarView(tab: tab) }
            }
        }
    }
}

private struct TabBarView: View {

    let tab: SentinelTabItem

    var body: some View {
        VStack(spacing: 5) {
            tab.barItemImage
                .renderingMode(.template)

            Text(tab.barItemTitle)
        }
    }
}
