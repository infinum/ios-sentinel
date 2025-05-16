//
//  SentinelTabItem.swift
//  
//
//  Created by Milos on 24.8.22..
//

import SwiftUI

struct SentinelTabItem {

    let tab: SentinelTab

    init(tab: SentinelTab) {
        self.tab = tab
    }
}

// MARK: - Helpers

extension SentinelTabItem {

    var barItemTitle: String {
        switch tab {
        case .device:
            return "Device"
        case .application:
            return "Application"
        case .tools:
            return "Tools"
        case .preferences:
            return "Preferences"
        case .performance:
            return "Performance"
        }
    }

    var barItemImage: Image? {
        switch tab {
        case .device: .image("device")
        case .application: .image("application")
        case .tools: .image("tools")
        case .preferences: .image("preferences")
        case .performance: .image("performance")
        }
    }

    var tabViewTab: Tab {
        switch tab {
        case .device: .device
        case .application: .application
        case .tools: .tools
        case .preferences: .preferences
        case .performance: .performance
        }
    }

    var sections: [ToolTableSection] {
        toolTable.sections
    }
}

// MARK: - Private helpers

private extension SentinelTabItem {

    var toolTable: ToolTable {
        switch tab {
        case .device:
            let deviceInfoItem = DeviceTool()
            let toolTable = deviceInfoItem.toolTable
            return toolTable
        case .application:
            let applicationInfoTool = ApplicationTool()
            let toolTable = applicationInfoTool.toolTable
            return toolTable
        case .tools(let items):
            let navigationItems = items
                .map { tool in
                    #if os(macOS)
                    ToolTableItem.navigation(NavigationToolItem(title: tool.name, didSelect: { tool.createContent(selection: $0) }))
                    #else
                    ToolTableItem.navigation(NavigationToolItem(title: tool.name, didSelect: { tool.content }))
                    #endif
                }
            let section = ToolTableSection(title: "Custom Tools", items: navigationItems)
            let toolTable = ToolTable(name: barItemTitle, sections: [section])
            return toolTable
        case .preferences(let items):
            let preferencesTool = PreferencesTool(sections: items)
            let toolTable = preferencesTool.toolTable
            return toolTable
        case .performance:
            let performanceInfoTool = PerformanceTool()
            let toolTable = performanceInfoTool.toolTable
            return toolTable
        }
    }
}
