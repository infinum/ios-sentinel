//
//  SentinelTabItemTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing
@testable import Sentinel

@Suite("Sentinel tabs")
struct SentinelTabItemTests {

    private let tabItems = Sentinel.createTabItems(
        with: [
            MockTool(name: "First"),
            MockTool(name: "Second")
        ],
        preferences: []
    )

    @Test("Tabs are laid out as Device, Application, Tools, Preferences, Performance")
    func tabOrder() {
        #expect(tabItems.map(\.tabViewTab) == [.device, .application, .tools, .preferences, .performance])
        #expect(tabItems.map(\.barItemTitle) == ["Device", "Application", "Tools", "Preferences", "Performance"])
    }

    @Test("The Tools tab lists every configured tool under Custom Tools")
    func toolsTabListsTools() throws {
        let toolsTab = try #require(tabItems.first { $0.tabViewTab == .tools })

        #expect(toolsTab.sections.map(\.title) == ["Custom Tools"])
        #expect(toolsTab.sections.first?.items.map(\.id) == ["First", "Second"])
    }

    @Test("The Tools tab is preselected")
    func toolsTabIsPreselected() {
        // `preselectedTabIndex` ignores its `tab` argument and always looks for the Tools tab.
        #expect(Sentinel().preselectedTabIndex(for: .device, tabItems: tabItems) == 2)
        #expect(Sentinel().preselectedTabIndex(for: .performance, tabItems: tabItems) == 2)
    }

    @Test("Without a Tools tab the first tab is preselected")
    func preselectionFallsBackToFirstTab() {
        let tabs = [
            SentinelTabItem(tab: .device),
            SentinelTabItem(tab: .performance)
        ]

        #expect(Sentinel().preselectedTabIndex(for: .device, tabItems: tabs) == 0)
    }

    @Test("Every tab builds its sections")
    func everyTabHasSections() {
        for tabItem in tabItems where tabItem.tabViewTab != .preferences {
            #expect(!tabItem.sections.isEmpty, "\(tabItem.barItemTitle) has no sections")
        }
    }
}
