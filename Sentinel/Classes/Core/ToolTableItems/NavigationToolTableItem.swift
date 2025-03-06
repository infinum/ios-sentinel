//
//  NavigationToolTableItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 13.12.2024..
//

import SwiftUI

/// Item which has a title, and by tapping on it will lead to another screen
public struct NavigationToolItem {
    let title: String
    let value: String?
    #if os(iOS)
    let didSelect: () -> any View
    #else
    /// Binding is provided from the parent screen, which should be set to nil if we want to navigate the user back once they perform an action
    let didSelect: (Binding<String?>) -> any View
    #endif
}

extension NavigationToolItem {

    #if os(iOS)
    init(title: String, itemValue: String? = nil, didSelect: @escaping () -> any View) {
        self.title = title
        self.didSelect = didSelect
        value = itemValue
    }
    #else
    init(title: String, itemValue: String? = nil, didSelect: @escaping (Binding<String?>) -> any View) {
        self.title = title
        self.didSelect = didSelect
        value = itemValue
    }
    #endif
}

// MARK: - Equatable conformance

extension NavigationToolItem: Equatable {

    public static func == (lhs: NavigationToolItem, rhs: NavigationToolItem) -> Bool {
        lhs.title == rhs.title
    }
}

// MARK: - Identifiable conformance

extension NavigationToolItem: Identifiable {

    public var id: String {
        title
    }
}
