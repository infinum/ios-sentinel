//
//  CustomInfoTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit
import SwiftUI

@objcMembers
public class CustomInfoTool: NSObject, Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Internal properties
    
    let info: [Section]

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

    @ViewBuilder
    public var content: any View {
        SentinelListView(title: name, items: createToolTable(with: info).sections)
    }

    // MARK: - Internal methods

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

extension CustomInfoTool {
    
    public class Section {
        
        // MARK: - Internal properties
        
        let title: String?
        let items: [Item]
        
        // MARK: - Lifecycle

        public init(title: String? = nil, items: [Item]) {
            self.title = title
            self.items = items
        }
    }
    
    public class Item: Equatable, Identifiable {

        // MARK: - Internal properties

        let title: String
        let value: String

        // MARK: - Lifecycle
        
        public init(title: String, value: String) {
            self.title = title
            self.value = value
        }

        public var id: String {
            title
        }

        public static func == (lhs: CustomInfoTool.Item, rhs: CustomInfoTool.Item) -> Bool {
            lhs.title == rhs.title
        }
    }
    
}
