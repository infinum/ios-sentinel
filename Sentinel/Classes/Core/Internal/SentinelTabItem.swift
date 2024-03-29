//
//  SentinelTabItem.swift
//  
//
//  Created by Milos on 24.8.22..
//

import UIKit

struct SentinelTabItem {

    let tab: SentinelTab

    init(tab: SentinelTab) {
        self.tab = tab
    }

    var viewController: UIViewController {
        switch tab {
        case .device:
            let deviceVC = SentinelTableViewController.create(with: toolTable)
            deviceVC.tabBarItem = tabBarItem
            return deviceVC
        case .application:
            let applicationVC = SentinelTableViewController.create(with: toolTable)
            applicationVC.tabBarItem = tabBarItem
            return applicationVC
        case .tools:
            let toolsVC = SentinelTableViewController.create(with: toolTable)
            toolsVC.tabBarItem = tabBarItem
            return toolsVC
        case .preferences:
            let preferencesVC = SentinelTableViewController.create(with: toolTable)
            preferencesVC.tabBarItem = tabBarItem
            return preferencesVC
        case .performance:
            let performanceVC = SentinelTableViewController.create(with: toolTable)
            performanceVC.tabBarItem = tabBarItem
            return performanceVC
        }
    }
}

private extension SentinelTabItem {

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

    var barItemImage: UIImage {
        switch tab {
        case .device:
            guard let image = UIImage.SentinelImages.device else { return UIImage() }
            return image
        case .application:
            guard let image = UIImage.SentinelImages.application else { return UIImage() }
            return image
        case .tools:
            guard let image = UIImage.SentinelImages.tools else { return UIImage() }
            return image
        case .preferences:
            guard let image = UIImage.SentinelImages.preferences else { return UIImage() }
            return image
        case .performance:
            guard let image = UIImage.SentinelImages.performance else { return UIImage() }
            return image
        }
    }

    var tabBarItem: UITabBarItem {
        return UITabBarItem(
            title: barItemTitle,
            image: barItemImage,
            selectedImage: barItemImage
        )
    }

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
                .map { NavigationToolTableItem(title: $0.name, navigate: $0.presentPreview(from:)) }
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
