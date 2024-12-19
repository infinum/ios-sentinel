//
//  ToolTable.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import SwiftUI

/// Defines tool datasouce which can present different tool sections.
public struct ToolTable: Tool {

    // MARK: - Public properties
    
    public let name: String

    // MARK: - Internal properties

    /// Tool sections in the table view.
    let sections: [ToolTableSection]
    
    // MARK: - Lifecycle
    
    /// Creates an instance of the tool table.
    public init(name: String, sections: [ToolTableSection]) {
        self.name = name
        self.sections = sections
    }
}

// MARK: - Extensions -

// MARK: - UI

public extension ToolTable {

    var content: any View {
        SentinelListView(title: name, items: sections)
    }
}
