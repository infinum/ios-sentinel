//
//  OptionSwitchTool.swift
//  ToolBox
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
    
    // MARK: - Private properties
    
    private let items: [OptionSwitchItem]
    
    // MARK: - Lifecycle
    
    public init(name: String = "Option Switch Tool", items: [OptionSwitchItem]) {
        self.name = name
        self.items = items
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let section = ToolTableSection(
            title: nil,
            items: items
        )
        let toolTable = ToolTable(name: name, sections: [section])
        toolTable.presentPreview(from: viewController)
    }
}
