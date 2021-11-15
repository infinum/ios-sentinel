//
//  CustomInfoTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objcMembers
public class CustomInfoTool: NSObject, Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Private properties
    
    internal let info: [Section]

    // MARK: - Lifecycle
    
    public init(name: String, info: [Section]) {
        self.name = name
        self.info = info
    }
    
    // MARK: - Public properties
    
    public func presentPreview(from viewController: UIViewController) {
        let toolTable = createToolTable(with: info)
        toolTable.presentPreview(from: viewController)
    }

    // MARK: - Internal properties

    internal func createToolTable(with info: [Section]) -> ToolTable {
        let sections = info.map { (section) in
            ToolTableSection(
                title: section.title,
                items: section.items.map { DetailToolTableItem(title: $0.title, detail: $0.value) }
            )
        }
        return ToolTable(name: name, sections: sections)
    }
}

extension CustomInfoTool {
    
    public class Section {
        
        // MARK: - Public properties
        
        let title: String?
        let items: [Item]
        
        // MARK: - Lifecycle

        public init(title: String? = nil, items: [Item]) {
            self.title = title
            self.items = items
        }
    }
    
    public class Item {
        
        // MARK: - Public properties

        let title: String
        let value: String

        // MARK: - Lifecycle
        
        public init(title: String, value: String) {
            self.title = title
            self.value = value
        }
    }
    
}
