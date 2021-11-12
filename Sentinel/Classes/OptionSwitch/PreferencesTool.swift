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
public class PreferencesTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String

    // MARK: - Private properties
    
    private let items: [OptionSwitchItem]
    
    // MARK: - Lifecycle
    
    public init(name: String = "Preferences", items: [OptionSwitchItem]) {
        self.name = name
        self.items = items
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let toolTable = createToolTable(with: items)
        toolTable.presentPreview(from: viewController)
    }
}

internal extension PreferencesTool {
    func createToolTable(with items: [OptionSwitchItem]) -> ToolTable {
        let section = ToolTableSection(
            title: nil,
            items: items
        )
        return ToolTable(name: name, sections: [section])
    }
}