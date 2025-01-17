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
        case .device: .SentinelImages.device
        case .application: .SentinelImages.application
        case .tools: .SentinelImages.tools
        case .preferences: .SentinelImages.preferences
        case .performance: .SentinelImages.performance
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
                .map { tool in ToolTableItem.navigation(.init(title: tool.name, didSelect: { tool.content })) }
            let section = ToolTableSection(title: barItemTitle, items: navigationItems)
            let toolTable = ToolTable(name: barItemTitle, sections: [section])
            return toolTable
        case .preferences(let items):
            let preferencesTool = PreferencesTool(items: items)
            let toolTable = preferencesTool.toolTable
            return toolTable
        case .performance:
            let performanceInfoTool = PerformanceTool()
            let toolTable = performanceInfoTool.toolTable
            return toolTable
        }
    }
}
