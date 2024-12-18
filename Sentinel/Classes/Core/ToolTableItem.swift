//
//  ToolTableItem.swift
//  Sentinel
//
//  Created by Nikola Majcen on 29/09/2020.
//

import SwiftUI

/// Enum with predefined Views which can be used with the ToolTable.
/// Navigation, Toggle, CustomInfo, and Performance have predefined Views.
/// In case a custom view is needed use the Custom case with a custom Item which conforms to CustomToolTableItem.
public enum ToolTableItem {
    case navigation(NavigationToolItem)
    case toggle(ToggleToolItem)
    case customInfo(CustomInfoTool.Item)
    case performance(PerformanceInfoItem)
    case custom(any CustomToolTableItem)
}

// MARK: - Extensions -

// MARK: - Identifiable conformance

extension ToolTableItem: Identifiable {

    public var id: String {
        switch self {
        case .navigation(let item): item.id
        case .toggle(let item): item.id
        case .customInfo(let item): item.id
        case .performance(let item): item.id
        case .custom(let item): item.id
        }
    }
}
