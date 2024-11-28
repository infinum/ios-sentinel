//
//  ToolTableSection.swift
//  Sentinel
//
//  Created by Nikola Majcen on 29/09/2020.
//

import Foundation

/// Represents tool section in the tool table view.
@objcMembers
public class ToolTableSection: NSObject {
    
    // MARK: - Internal properties
    
    /// The title of the section.
    let title: String?
    
    /// Tool items available in the section.
    let items: [ToolTableItem2]

    // MARK: - Lifecycle
    
//    /// Creates an instance of the section.
//    public init(title: String? = nil, items: [ToolTableItem]) {
//        self.title = title
//        self.items = []
//        super.init()
//    }

    public init(title: String? = nil, items: [ToolTableItem2]) {
        self.title = title
        self.items = items
        super.init()
    }
}
