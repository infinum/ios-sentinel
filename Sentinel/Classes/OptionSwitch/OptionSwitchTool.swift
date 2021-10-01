//
//  OptionSwitchTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import Foundation

/// Provides functionality which gives the user ability
/// to change environment variables in the application.
@objcMembers
public class OptionSwitchTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String
    public var type: ViewControllerType = .permissions

    // MARK: - Private properties
    
    private let items: [OptionSwitchItem]
    
    // MARK: - Lifecycle
    
    public init(name: String = "Permissions", items: [OptionSwitchItem]) {
        self.name = name
        self.items = items
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let toolTable = createToolTable(with: items)
        toolTable.presentPreview(from: viewController)
    }

    public func createViewController(on viewController: UIViewController?) -> UIViewController {
        let toolTable = createToolTable(with: items)
        let controller = toolTable.createViewController(on: nil)
        controller.tabBarItem = UITabBarItem(title: "Permissions", image: UIImage.resize(UIImage.loadFromBundle(name: "permissions")), tag: 2)
        return controller
    }
}

private extension OptionSwitchTool {
    func createToolTable(with items: [OptionSwitchItem]) -> ToolTable {
        let section = ToolTableSection(
            title: nil,
            items: items
        )
        return ToolTable(name: name, sections: [section])
    }
}
