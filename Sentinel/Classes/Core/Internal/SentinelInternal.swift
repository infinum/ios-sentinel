//
//  SentinelInternal.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation
import UIKit

extension Sentinel {
    
    /// Presents the Sentinel with tools from provided view controller.
    ///
    /// - Parameters:
    ///     - tools: Tools which will be available in the Sentinel.
    ///     - optionSwitchItems: items which can allow or deny an activity inside the app
    ///     - viewController: The view controller from where will the Sentinel be presented.
    func present(tools: [Tool], optionSwitchItems: [OptionSwitchItem], on viewController: UIViewController) {
        let tabBarControllers = createTabBarControllers(with: tools, optionSwitchItems: optionSwitchItems, viewController: viewController)
        let tabBarController = UIStoryboard.sentinel.instantiateViewController(ofType: SentinelTabBarController.self)
        tabBarController.setupViewControllers(with: tabBarControllers)
        tabBarController.title = "Sentinel"

        let navController = UINavigationController(rootViewController: tabBarController)
        viewController.present(navController, animated: true)
    }
}

private extension Sentinel {
    func createTabBarControllers(with tools: [Tool], optionSwitchItems: [OptionSwitchItem], viewController: UIViewController) -> [UIViewController] {
        var tabBarControllers: [UIViewController] = []
        tabBarControllers.append(createDeviceViewController())
        tabBarControllers.append(createApplicationViewController())
        tabBarControllers.append(createToolsController(with: tools, viewController: viewController))
        tabBarControllers.append(createPreferencesViewController(optionSwitchItems))
        tabBarControllers.append(createPerformanceViewController())
        return tabBarControllers
    }

    func createToolsController(with tools: [Tool], viewController: UIViewController) -> UIViewController {
        let navigationItems = tools
            .map { NavigationToolTableItem(title: $0.name, navigate: $0.presentPreview(from:)) }
        let section = ToolTableSection(title: "Tools", items: navigationItems)
        let toolTable = ToolTable(name: "Tools", sections: [section])
        let toolsViewController = SentinelTableViewController.create(with: toolTable)
        toolsViewController.tabBarItem = UITabBarItem(
            title: "Tools",
            image: UIImage.Sentinel.tools.resize(),
            tag: 2
        )
        return toolsViewController
    }

    func createDeviceViewController() -> UIViewController {
        let deviceInfoItem = DeviceTool().tool
        let toolTable = deviceInfoItem.createToolTable(with: deviceInfoItem.info)
        let viewController = SentinelTableViewController.create(with: toolTable)
        viewController.tabBarItem = UITabBarItem(
            title: "Device",
            image: UIImage.Sentinel.device.resize(),
            tag: 0
        )
        return viewController
}

    func createApplicationViewController() -> UIViewController {
        let applicationInfoTool = ApplicationTool().tool
        let toolTable = applicationInfoTool.createToolTable(with: applicationInfoTool.info)
        let viewController = SentinelTableViewController.create(with: toolTable)
        viewController.tabBarItem = UITabBarItem(
            title: "Application",
            image: UIImage.Sentinel.application.resize(),
            tag: 1
        )
        return viewController
    }

    func createPreferencesViewController(_ items: [OptionSwitchItem]) -> UIViewController {
        let preferencesTool = PreferencesTool(items: items)
        let toolTable = preferencesTool.createToolTable(with: items)
        let viewController = SentinelTableViewController.create(with: toolTable)
        viewController.tabBarItem = UITabBarItem(
            title: "Preferences",
            image: UIImage.Sentinel.permissions.resize(),
            tag: 3
        )
        return viewController
    }

    func createPerformanceViewController() -> UIViewController {
        let performanceInfoTool = PerformanceTool()
        let toolTable = performanceInfoTool.createToolTable()
        let viewController = SentinelTableViewController.create(with: toolTable)
        viewController.tabBarItem = UITabBarItem(
            title: "Performance",
            image: UIImage.Sentinel.performance.resize(),
            tag: 4
        )
        return viewController
    }
}
