//
//  SentinelInternal.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

extension Sentinel {
    
    /// Presents the Sentinel with tools from provided view controller.
    ///
    /// - Parameters:
    ///     - tools: Tools which will be available in the Sentinel.
    ///     - viewController: The view controller from where will the Sentinel be presented.
    func present(tools: [Tool], on viewController: UIViewController) {
        let tabBarControllers = createTabBarControllers(with: tools, viewController: viewController)
        let tabBarController = UIStoryboard.sentinel.instantiateViewController(ofType: SentinelTabBarController.self)
        tabBarController.setupViewControllers(with: tabBarControllers)
        tabBarController.title = "Sentinel"

        let navContoller = UINavigationController(rootViewController: tabBarController)
        viewController.present(navContoller, animated: true)
    }
}

private extension Sentinel {
    func createTabBarControllers(with tools: [Tool], viewController: UIViewController) -> [UIViewController] {
        var tabBarControllers = tools.filter { tool in
            return tool.type == .application ||
            tool.type == .permissions ||
            tool.type == .performance
        }.map { $0.createViewController(on: viewController) }
        let toolsViewController = createToolsController(with: tools, viewController: viewController)
        let deviceViewController = createDeviceViewController()

        tabBarControllers.insert(deviceViewController, at: 0)
        tabBarControllers.insert(toolsViewController, at: 2)
        return tabBarControllers
    }

    func createToolsController(with tools: [Tool], viewController: UIViewController) -> UIViewController {
        let navigationItems = tools.filter { tool in
            return tool.type != .application &&
            tool.type != .permissions &&
            tool.type != .performance
        }.map { NavigationToolTableItem(title: $0.name, navigate: $0.presentPreview(from:)) }

        let section = ToolTableSection(title: "Tools", items: navigationItems)
        let toolsViewController = ToolTable(name: "Tools", sections: [section]).createViewController(on: viewController)
        toolsViewController.tabBarItem = UITabBarItem(title: "Tools", image: UIImage.resize(UIImage.loadFromBundle(name: "tools")), tag: 2)
        return toolsViewController
    }

    func createDeviceViewController() -> UIViewController {
        let deviceInfoItem = DeviceInfoTool()
        return deviceInfoItem.createViewController()
    }
}
