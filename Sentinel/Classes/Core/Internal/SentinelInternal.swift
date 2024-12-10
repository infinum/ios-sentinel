//
//  SentinelInternal.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import SwiftUI

extension Sentinel {
    
    /// Presents the Sentinel with tools from provided view controller.
    ///
    /// - Parameters:
    ///     - tools: Tools which will be available in the Sentinel.
    ///     - preferences: items which can allow or deny an activity inside the app
    ///     - viewController: The view controller from where will the Sentinel be presented.
    func present(
        tools: [Tool],
        preferences: [ToolTableSection],
        on viewController: UIViewController
    ) {
        let tabItems = createTabItems(
            with: tools,
            preferences: preferences,
            viewController: viewController
        )

        let tabBarController = UIHostingController(rootView: SentinelTabBarView(tabs: tabItems))

        let navController = UINavigationController(rootViewController: tabBarController)
        viewController.present(navController, animated: true)
    }
}

// MARK: - Private extension

private extension Sentinel {
    func createTabItems(
        with tools: [Tool],
        preferences: [ToolTableSection],
        viewController: UIViewController
    ) -> [SentinelTabItem] {
        [
            SentinelTabItem(tab: .device),
            SentinelTabItem(tab: .application),
            SentinelTabItem(tab: .tools(items: tools)),
            SentinelTabItem(tab: .preferences(items: preferences)),
            SentinelTabItem(tab: .performance)
        ]
    }

    func preselectedTabIndex(for tab: SentinelTab, tabItems: [SentinelTabItem]) -> Int {
        tabItems
            .enumerated()
            .first(where: {
                guard case .tools = $0.element.tab else { return false }
                return true
            })
            .map(\.offset) ?? 0
    }
}
