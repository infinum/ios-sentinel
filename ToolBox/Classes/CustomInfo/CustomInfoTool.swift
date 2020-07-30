//
//  CustomInfoTool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

public class CustomInfoTool: Tool {
    
    public let name: String
    private let info: [Section]

    public init(name: String, info: [Section]) {
        self.name = name
        self.info = info
    }
    
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

public extension CustomInfoTool {
    
    class Section {
        let title: String?
        let items: [Item]

        public init(title: String? = nil, items: [Item]) {
            self.title = title
            self.items = items
        }
    }
    
    class Item {
        let title: String
        let value: String

        public init(title: String, value: String) {
            self.title = title
            self.value = value
        }
    }
    
}
