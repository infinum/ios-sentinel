//
//  OptionSwitchTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import SwiftUI

/// Provides functionality which gives the user ability
/// to change environment variables in the application.
struct PreferencesTool: Tool {

    // MARK: - Public properties
    
    public let name: String

    // MARK: - Private properties
    
    private let items: [ToolTableSection]

    // MARK: - Lifecycle
    
    public init(name: String = "Preferences", items: [ToolTableSection]) {
        self.name = name
        self.items = items
    }
}

// MARK: - Extensions -

// MARK: - UI

extension PreferencesTool {

    var toolTable: ToolTable {
        createToolTable(with: items)
    }

    var content: any View {
        SentinelListView(title: name, items: toolTable.sections)
    }
}

// MARK: - Private extension

private extension PreferencesTool {

    func createToolTable(with items: [ToolTableSection]) -> ToolTable {
        ToolTable(name: name, sections: items)
    }
}
