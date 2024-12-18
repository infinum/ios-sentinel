//
//  CustomInfoTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import SwiftUI

public struct CustomInfoTool: Tool {

    // MARK: - Public properties
    
    public let name: String

    // MARK: - Internal properties
    
    let info: [Section]

    // MARK: - Lifecycle
    
    public init(name: String, info: [Section]) {
        self.name = name
        self.info = info
    }
}

// MARK: - Extensions -

// MARK: - UI

public extension CustomInfoTool {

    var content: any View {
        SentinelListView(title: name, items: createToolTable(with: info).sections)
    }

}

// MARK: - Helpers

extension CustomInfoTool {

    func createToolTable(with info: [Section]) -> ToolTable {
        let sections = info.map { (section) in
            ToolTableSection(
                title: section.title,
                items: section.items.map { .customInfo($0) }
            )
        }
        return ToolTable(name: name, sections: sections)
    }

}
