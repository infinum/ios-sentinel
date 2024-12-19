//
//  CustomToolTableItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 13.12.2024..
//

import SwiftUI

/// Item protocol which can be used with ToolTable to show a custom UI
public protocol CustomToolTableItem: Identifiable, Equatable {
    var title: String { get }
    @ViewBuilder var content: any View { get }
}

// MARK: - Extensions -

// MARK: - Identifiable helper

public extension CustomToolTableItem {
    var id: String { title }
}
