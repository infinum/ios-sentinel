//
//  PerformanceInfoTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit
import SwiftUI

final class PerformanceTool: Tool {

    // MARK: - Public properties
    
    public let name: String

    // MARK: - Lifecycle
    
    public init(name: String = "Performance") {
        self.name = name
    }

    // MARK: - Internal properties

    var toolTable: ToolTable {
        return createToolTable()
    }

    var content: any View {
        SentinelListView(items: toolTable.sections)
    }

    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let toolTable = createToolTable()
        toolTable.presentPreview(from: viewController)
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

    func cpuInfoItems() -> [ToolTableItem2] {
        let cpuInfo = CPUInfoProvider()
        return [
            .performance(.init(title: "CPU Usage", valueDidChange: { String(format: "%.2f%%", cpuInfo.currentUsage) })),
            .performance(PerformanceInfoItem(title: "Number of cores", valueDidChange: { String(format: "%d", cpuInfo.numberOfCores) }))
        ]
    }

    func memoryInfoItems() -> [ToolTableItem2] {
        let memoryInfo = MemoryInfoProvider()
        let used = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.used, countStyle: .file)
        let total = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.total, countStyle: .file)
        return [
            .performance(PerformanceInfoItem(title: "Memory usage", valueDidChange: { "\(used) / \(total)" }))
        ]
    }

    func systemInfoItems() -> [ToolTableItem2] {
        let systemInfo = SystemInfoProvider()
        return [
            .performance(PerformanceInfoItem(title: "Uptime", valueDidChange: { systemInfo.uptime }))
        ]
    }

}
