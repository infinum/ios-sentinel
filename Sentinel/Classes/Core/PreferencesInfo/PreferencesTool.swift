//
//  OptionSwitchTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

/// Provides functionality which gives the user ability
/// to change environment variables in the application.
class PreferencesTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String

    // MARK: - Private properties
    
    private let items: [PreferenceItem]

    // MARK: - Internal properties

    var toolTable: ToolTable {
        return createToolTable(with: items)
    }
    
    // MARK: - Lifecycle
    
    public init(name: String = "Preferences", items: [PreferenceItem]) {
        self.name = name
        self.items = items
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let toolTable = createToolTable(with: items)
        toolTable.presentPreview(from: viewController)
    }
}

// MARK: - Private extension

private extension PreferencesTool {
    func createToolTable(with items: [PreferenceItem]) -> ToolTable {
        let section = ToolTableSection(
            title: nil,
            items: items
        )
        return ToolTable(name: name, sections: [section])
    }
}
