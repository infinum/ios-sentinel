//
//  CustomInfoToolSection.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 18.12.2024..
//

import Foundation

public extension CustomInfoTool {

    /// Section Item for the CustomInfoTool which expects CustomInfoTool.Item for its items
    struct Section {

        // MARK: - Internal properties

        let title: String?
        let items: [Item]

        // MARK: - Lifecycle

        public init(title: String? = nil, items: [Item]) {
            self.title = title
            self.items = items
        }
    }

    /// Row Item for the CustomInfoTool which will show a title + value pair
    struct Item {

        // MARK: - Internal properties

        let title: String
        let value: String

        // MARK: - Lifecycle

        public init(title: String, value: String) {
            self.title = title
            self.value = value
        }
    }

}

// MARK: - Equatable conformance

extension CustomInfoTool.Item: Equatable {

    public static func == (lhs: CustomInfoTool.Item, rhs: CustomInfoTool.Item) -> Bool {
        lhs.title == rhs.title
    }
}

// MARK: - Identifiable conformance

extension CustomInfoTool.Item: Identifiable {

    public var id: String {
        title
    }
}
