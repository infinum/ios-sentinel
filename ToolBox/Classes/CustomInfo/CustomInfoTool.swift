//
//  CustomInfoTool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objcMembers
public class CustomInfoTool: NSObject, Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Private properties
    
    private let info: [Section]

    // MARK: - Lifecycle
    
    public init(name: String, info: [Section]) {
        self.name = name
        self.info = info
        super.init()
    }
    
    // MARK: - Public properties
    
    public func presentPreview(from viewController: UIViewController) {
        let sections = info.map { (section) in
            ToolTableSection(
                title: section.title,
                items: section.items.map { DetailToolTableItem(title: $0.title, detail: $0.value) }
            )
        }
        let toolTable = ToolTable(name: name, sections: sections)
        toolTable.presentPreview(from: viewController)
    }
}

@objc
extension CustomInfoTool {
    
    @objcMembers
    @objc(CustomInfoToolSection)
    public class Section: NSObject {
        
        // MARK: - Public properties
        
        let title: String?
        let items: [Item]
        
        // MARK: - Lifecycle

        public init(title: String? = nil, items: [Item]) {
            self.title = title
            self.items = items
            super.init()
        }
    }
    
    @objcMembers
    @objc(CustomInfoToolItem)
    public class Item: NSObject {
        
        // MARK: - Public properties

        let title: String
        let value: String

        // MARK: - Lifecycle
        
        public init(title: String, value: String) {
            self.title = title
            self.value = value
            super.init()
        }
    }
    
}
