//
//  NavigationToolTableItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 13.12.2024..
//

import SwiftUI

public struct NavigationToolItem {
    let title: String
    let didSelect: () -> any View
}

// MARK: - Extensions

// MARK: - Equatable and Identifiable conformance

extension NavigationToolItem: Equatable, Identifiable {

    public var id: String { title }

    public static func == (lhs: NavigationToolItem, rhs: NavigationToolItem) -> Bool {
        lhs.title == rhs.title
    }

}
