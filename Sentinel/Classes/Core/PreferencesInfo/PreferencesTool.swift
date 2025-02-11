//
//  OptionSwitchTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import SwiftUI

/// Tool which gives the user ability to change environment variables in the application.
/// Options are grouped into sections for a better overview of different types of preferences.
public struct PreferencesTool: Tool {

    // MARK: - Public properties
    
    public let name: String

    // MARK: - Private properties
    
    private let sections: [ToolTableSection]

    // MARK: - Lifecycle
    
    public init(name: String = "Preferences", sections: [PreferencesTool.Section]) {
        self.name = name
        self.sections = sections.map {
            ToolTableSection(title: $0.title, items: $0.items.map { item in ToolTableItem.toggle(item) })
        }
    }
}

// MARK: - UI

extension PreferencesTool {

    var toolTable: ToolTable {
        createToolTable(with: sections)
    }

    #if os(macOS)
    public func createContent(selection: Binding<String?>) -> any View  {
        SentinelListView(title: name, items: toolTable.sections)
    }
    #else
    public var content: any View {
        SentinelListView(title: name, items: toolTable.sections)
    }
    #endif
}

// MARK: - Private extension

private extension PreferencesTool {

    func createToolTable(with items: [ToolTableSection]) -> ToolTable {
        ToolTable(name: name, sections: items)
    }
}
