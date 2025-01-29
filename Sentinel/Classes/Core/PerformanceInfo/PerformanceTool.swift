//
//  PerformanceInfoTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import SwiftUI

/// Tool which shows the current state of the CPU, memory, system and App duration
struct PerformanceTool: Tool {

    // MARK: - Public properties
    
    public let name: String

    // MARK: - Lifecycle
    
    public init(name: String = "Performance") {
        self.name = name
    }
}

// MARK: - UI

extension PerformanceTool {

    var toolTable: ToolTable {
        createToolTable()
    }

    var content: any View {
        SentinelListView(title: name, items: toolTable.sections)
    }
}

// MARK: - Private methods

private extension PerformanceTool {

    func createToolTable() -> ToolTable {
        return ToolTable(
            name: name,
            sections: [
                ToolTableSection(title: "CPU", items: cpuInfoItems()),
                ToolTableSection(title: "Memory", items: memoryInfoItems()),
                ToolTableSection(title: "System", items: systemInfoItems())
            ]
        )
    }

    func cpuInfoItems() -> [ToolTableItem] {
        let cpuInfo = CPUInfoProvider()
        return [
            .performance(PerformanceInfoItem(title: "CPU Usage", valueDidChange: { String(format: "%.2f%%", cpuInfo.currentUsage) })),
            .performance(PerformanceInfoItem(title: "Number of cores", valueDidChange: { String(format: "%d", cpuInfo.numberOfCores) }))
        ]
    }

    func memoryInfoItems() -> [ToolTableItem] {
        let memoryInfo = MemoryInfoProvider()
        let used = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.used, countStyle: .file)
        let total = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.total, countStyle: .file)
        return [
            .performance(PerformanceInfoItem(title: "Memory usage", valueDidChange: { "\(used) / \(total)" }))
        ]
    }

    func systemInfoItems() -> [ToolTableItem] {
        let systemInfo = SystemInfoProvider()
        return [
            .performance(PerformanceInfoItem(title: "Uptime", valueDidChange: { systemInfo.uptime }))
        ]
    }

}
