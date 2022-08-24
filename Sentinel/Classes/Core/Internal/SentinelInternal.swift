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
        let tabItems = createTabItems(
            with: tools,
            preferences: preferences,
            viewController: viewController
        )
        let tabBarController = UIStoryboard.sentinel
            .instantiateViewController(ofType: SentinelTabBarController.self)
        let preselectedTabIndex = preselectedTabIndex(
            for: .tools(items: []),
            tabItems: tabItems
        )
        tabBarController.setupViewControllers(
            with: tabItems.map { $0.viewController },
            preselectedIndex: preselectedTabIndex
        )
        tabBarController.title = "Sentinel"

        let navController = UINavigationController(rootViewController: tabBarController)
        viewController.present(navController, animated: true)
    }
}

// MARK: - Private extension

private extension Sentinel {
    func createTabItems(
        with tools: [Tool],
        preferences: [OptionSwitchItem],
        viewController: UIViewController
    ) -> [TabItem] {
        return [
            TabItem(tab: .device),
            TabItem(tab: .application),
            TabItem(tab: .tools(items: tools)),
            TabItem(tab: .preferences(items: preferences)),
            TabItem(tab: .performance)
        ]
    }

    func preselectedTabIndex(for tab: Tab, tabItems: [TabItem]) -> Int {
        return tabItems
            .enumerated()
            .first(where: {
                guard case .tools = $0.element.tab else { return false }
                return true
            })
            .map(\.offset) ?? 0
    }
}
