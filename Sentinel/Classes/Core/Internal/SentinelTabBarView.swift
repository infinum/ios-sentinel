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

/// Container View which holds all of the Sentinel tabs. Can only be instantiated via Sentinel.createSentinelView(with:) function.
public struct SentinelTabBarView: View {

    @State private var selectedTab: Tab = .tools
    private let tabs: [SentinelTabItem]

    init(tabs: [SentinelTabItem]) {
        self.tabs = tabs
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabs, id: \.barItemTitle) { tab in
                #if os(macOS)
                SentinelListView(title: tab.barItemTitle, items: tab.sections)
                    .tabItem { TabBarView(tab: tab) }
                #else
                NavigationView {
                    SentinelListView(title: tab.barItemTitle, items: tab.sections)
                }
                .tabItem { TabBarView(tab: tab) }
                #endif
            }
        }
    }
}

private struct TabBarView: View {

    let tab: SentinelTabItem

    var body: some View {
        VStack(spacing: 5) {
            if let image = tab.barItemImage {
                image
                    .renderingMode(.template)
            }

            Text(tab.barItemTitle)
        }
    }
}
