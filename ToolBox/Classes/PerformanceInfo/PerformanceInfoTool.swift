//
//  PerformanceInfoTool.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

public class PerformanceInfoTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Lifecycle
    
    public init(name: String = "Performance Info") {
        self.name = name
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let toolTable = ToolTable(
            name: name,
            sections: [
                ToolTableSection(title: "CPU", items: cpuInfoItems()),
                ToolTableSection(title: "Memory", items: memoryInfoItems()),
                ToolTableSection(title: "System", items: systemInfoItems())
            ]
        )
        toolTable.presentPreview(from: viewController)
    }
}

private extension PerformanceInfoTool {

    func cpuInfoItems() -> [ToolTableItem] {
        let cpuInfo = CPUInfoProvider()
        return [
            PerformanceInfoItem(title: "CPU usage", value: String(format: "%.2f%%", cpuInfo.currentUsage)),
            PerformanceInfoItem(title: "Number of cores", value: String(format: "%d", cpuInfo.numberOfCores))
        ]
    }

    func memoryInfoItems() -> [ToolTableItem] {
        let memoryInfo = MemoryInfoProvider()
        let used = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.used, countStyle: .file)
        let total = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.total, countStyle: .file)
        return [
            PerformanceInfoItem(title: "Memory usage", value: "\(used) / \(total)")
        ]
    }

    func systemInfoItems() -> [ToolTableItem] {
        let systemInfo = SystemInfoProvider()
        return [
            PerformanceInfoItem(title: "Uptime", value: systemInfo.uptime)
        ]
    }

}
