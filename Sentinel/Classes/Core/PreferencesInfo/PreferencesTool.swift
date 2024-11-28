//
//  OptionSwitchTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit
import SwiftUI

/// Provides functionality which gives the user ability
/// to change environment variables in the application.
class PreferencesTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String

    // MARK: - Private properties
    
    private let items: [ToolTableSection]

    // MARK: - Internal properties

    var toolTable: ToolTable {
        return createToolTable(with: items)
    }
    
    // MARK: - Lifecycle
    
    public init(name: String = "Preferences", items: [ToolTableSection]) {
        self.name = name
        self.items = items
    }

    var content: any View {
        SentinelListView(title: name, items: toolTable.sections)
    }

}

// MARK: - Private extension

private extension PreferencesTool {
    func createToolTable(with items: [ToolTableSection]) -> ToolTable {
        return ToolTable(name: name, sections: items)
    }
}
