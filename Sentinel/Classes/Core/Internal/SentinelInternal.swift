//
//  SentinelInternal.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

extension Sentinel {
    
    /// Presents the Sentinel with tools from provided view controller.
    ///
    /// - Parameters:
    ///     - tools: Tools which will be available in the Sentinel.
    ///     - preferences: items which can allow or deny an activity inside the app
    ///     - viewController: The view controller from where will the Sentinel be presented.
    func present(
        tools: [Tool],
        preferences: [OptionSwitchItem],
        on viewController: UIViewController
    ) {
        let tabBarControllers = createTabBarControllers(
            with: tools,
            preferences: preferences,
            viewController: viewController
        )
        let tabBarController = UIStoryboard.sentinel
            .instantiateViewController(ofType: SentinelTabBarController.self)
        tabBarController.setupViewControllers(with: tabBarControllers)
        tabBarController.title = "Sentinel"

        let navController = UINavigationController(rootViewController: tabBarController)
        viewController.present(navController, animated: true)
    }
}

enum Tabs {
    case device
    case application
    case tools(items: [Tool])
    case preferences(items: [OptionSwitchItem])
    case performance

    var index: Int {
        switch self {
        case .device:
            return 0
        case .application:
            return 1
        case .tools:
            return 2
        case .preferences:
            return 3
        case .performance:
            return 4
        }
    }

    var vc: UIViewController {
        switch self {
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

    var barItemTitle: String {
        switch self {
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
        switch self {
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
        switch self {
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

// MARK: - Private extension

private extension Sentinel {
    func createTabBarControllers(
        with tools: [Tool],
        preferences: [OptionSwitchItem],
        viewController: UIViewController
    ) -> [UIViewController] {
        return [
            Tabs.device,
            Tabs.application,
            Tabs.tools(items: tools),
            Tabs.preferences(items: preferences),
            Tabs.performance
        ]
            .map { $0.vc }
    }
}
