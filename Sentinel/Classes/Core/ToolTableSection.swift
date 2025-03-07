//
//  ToolTableSection.swift
//  Sentinel
//
//  Created by Nikola Majcen on 29/09/2020.
//

import Foundation

/// Represents tool section in the tool table view.
public struct ToolTableSection: Identifiable {

    // MARK: - Public properties

    public let id: String

    // MARK: - Internal properties
    
    /// The title of the section.
    let title: String?
    
    /// Tool items available in the section.
    let items: [ToolTableItem]

    // MARK: - Lifecycle

    public init(title: String? = nil, items: [ToolTableItem]) {
        self.title = title
        self.items = items
        id = title ?? UUID().uuidString
    }
}
