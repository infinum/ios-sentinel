//
//  SentinelInternal.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

// MARK: - Helpers

extension Sentinel {
    
    static func createTabItems(
        with tools: [Tool],
        preferences: [PreferencesTool.Section]
    ) -> [SentinelTabItem] {
        [
            SentinelTabItem(tab: .device),
            SentinelTabItem(tab: .application),
            SentinelTabItem(tab: .tools(items: tools)),
            SentinelTabItem(tab: .preferences(items: preferences)),
            SentinelTabItem(tab: .performance)
        ]
    }

    func preselectedTabIndex(for tab: SentinelTab, tabItems: [SentinelTabItem]) -> Int {
        tabItems
            .enumerated()
            .first(where: {
                guard case .tools = $0.element.tab else { return false }
                return true
            })
            .map(\.offset) ?? 0
    }
}
