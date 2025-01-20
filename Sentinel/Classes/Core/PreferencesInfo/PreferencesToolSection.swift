//
//  PreferenceSectionItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 20.01.2025..
//

import Foundation

extension PreferencesTool {

    /// Section Item for the CustomInfoTool which expects CustomInfoTool.Item for its items
    public struct Section {

        // MARK: - Public properties

        public let id: String

        // MARK: - Internal properties

        /// The title of the section.
        let title: String?

        /// Tool items available in the section.
        let items: [ToggleToolItem]

        public init(title: String?, items: [ToggleToolItem]) {
            self.title = title
            self.items = items
            id = title ?? UUID().uuidString
        }
    }

}
