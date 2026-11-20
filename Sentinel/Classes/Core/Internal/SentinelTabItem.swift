//
//  SentinelTabItem.swift
//  
//
//  Created by Milos on 24.8.22..
//

import SwiftUI

struct SentinelTabItem {

    let tab: SentinelTab
    /// When set, the screen gets a share button which shares the returned text.
    let shareText: (() -> String)?

    /// The Device and Application tabs' rows, read once here rather than on every SwiftUI update.
    private let infoSections: [ToolTableSection]

    /// - Parameter report: The device and application information the Device and Application tabs show and share.
    ///   Pass the same report to both, so they show the same values. Other tabs don't read it.
    init(tab: SentinelTab, report: @autoclosure () -> SentinelReport = SentinelReport()) {
        self.tab = tab
        switch tab {
        case .device:
            let report = report()
            infoSections = DeviceTool(sections: report.deviceSections).toolTable.sections
            shareText = { report.plainText }
        case .application:
            let report = report()
            let sections = report.applicationSections + [ApplicationInfoProvider.bundleAllInfoSection]
            infoSections = ApplicationTool(sections: sections).toolTable.sections
            shareText = { report.plainText }
        case .tools, .preferences, .performance:
            infoSections = []
            shareText = nil
        }
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

    var barItemImage: Image {
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
        case .device, .application:
            return ToolTable(name: barItemTitle, sections: infoSections)
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
