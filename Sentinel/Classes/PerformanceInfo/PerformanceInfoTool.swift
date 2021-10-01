//
//  PerformanceInfoTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

public class PerformanceInfoTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String
    public var type: ViewControllerType = .performance

    // MARK: - Lifecycle
    
    public init(name: String = "Performance") {
        self.name = name
    }

    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let toolTable = createToolTable()
        toolTable.presentPreview(from: viewController)
    }

    public func createViewController(on viewController: UIViewController?) -> UIViewController {
        let toolTable = createToolTable()
        let controller = toolTable.createViewController()
        controller.tabBarItem = UITabBarItem(title: "Performance", image: UIImage.resize(UIImage.loadFromBundle(name: "performance")), tag: 1)
        return controller
    }
}

// MARK: - Private methods

private extension PerformanceInfoTool {

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
            PerformanceInfoItem(title: "CPU Usage", valueDidChange: { String(format: "%.2f%%", cpuInfo.currentUsage) }),
            PerformanceInfoItem(title: "Number of cores", valueDidChange: { String(format: "%d", cpuInfo.numberOfCores) })
        ]
    }

    func memoryInfoItems() -> [ToolTableItem] {
        let memoryInfo = MemoryInfoProvider()
        let used = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.used, countStyle: .file)
        let total = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.total, countStyle: .file)
        return [
            PerformanceInfoItem(title: "Memory usage", valueDidChange: { "\(used) / \(total)" })
        ]
    }

    func systemInfoItems() -> [ToolTableItem] {
        let systemInfo = SystemInfoProvider()
        return [
            PerformanceInfoItem(title: "Uptime", valueDidChange: { systemInfo.uptime })
        ]
    }

}
