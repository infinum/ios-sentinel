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
    let didSelect: () -> any View
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
