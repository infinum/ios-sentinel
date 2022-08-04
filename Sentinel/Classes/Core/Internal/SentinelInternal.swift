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

// MARK: - Private extension

private extension Sentinel {
    func createTabBarControllers(
        with tools: [Tool],
        preferences: [OptionSwitchItem],
        viewController: UIViewController
    ) -> [UIViewController] {
        return [
            createDeviceViewController(),
            createApplicationViewController(),
            createToolsController(with: tools),
            createPreferencesViewController(preferences),
            createPerformanceViewController()
        ]
    }

    func createToolsController(with tools: [Tool]) -> UIViewController {
        let navigationItems = tools
            .map { NavigationToolTableItem(title: $0.name, navigate: $0.presentPreview(from:)) }
        let section = ToolTableSection(title: "Tools", items: navigationItems)
        let toolTable = ToolTable(name: "Tools", sections: [section])
        let toolsViewController = SentinelTableViewController.create(with: toolTable)
        toolsViewController.tabBarItem = UITabBarItem(
            title: "Tools",
            image: UIImage.SentinelImages.tools,
            selectedImage: UIImage.SentinelImages.tools
        )
        return toolsViewController
    }

    func createDeviceViewController() -> UIViewController {
        let deviceInfoItem = DeviceTool()
        let toolTable = deviceInfoItem.toolTable
        let viewController = SentinelTableViewController.create(with: toolTable)
        viewController.tabBarItem = UITabBarItem(
            title: "Device",
            image: UIImage.SentinelImages.device,
            selectedImage: UIImage.SentinelImages.device
        )
        return viewController
}

    func createApplicationViewController() -> UIViewController {
        let applicationInfoTool = ApplicationTool()
        let toolTable = applicationInfoTool.toolTable
        let viewController = SentinelTableViewController.create(with: toolTable)
        viewController.tabBarItem = UITabBarItem(
            title: "Application",
            image: UIImage.SentinelImages.application,
            selectedImage: UIImage.SentinelImages.application
        )
        return viewController
    }

    func createPreferencesViewController(_ items: [OptionSwitchItem]) -> UIViewController {
        let preferencesTool = PreferencesTool(items: items)
        let toolTable = preferencesTool.toolTable
        let viewController = SentinelTableViewController.create(with: toolTable)
        viewController.tabBarItem = UITabBarItem(
            title: "Preferences",
            image: UIImage.SentinelImages.preferences,
            selectedImage: UIImage.SentinelImages.preferences
        )
        return viewController
    }

    func createPerformanceViewController() -> UIViewController {
        let performanceInfoTool = PerformanceTool()
        let toolTable = performanceInfoTool.toolTable
        let viewController = SentinelTableViewController.create(with: toolTable)
        viewController.tabBarItem = UITabBarItem(
            title: "Performance",
            image: UIImage.SentinelImages.performance,
            selectedImage: UIImage.SentinelImages.performance
        )
        return viewController
    }
}
