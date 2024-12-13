//
//  ToolTableItem.swift
//  Sentinel
//
//  Created by Nikola Majcen on 29/09/2020.
//

import SwiftUI

public enum ToolTableItem: Identifiable {
    public var id: String {
        switch self {
        case .navigation(let item): item.id
        case .toggle(let item): item.id
        case .customInfo(let item): item.id
        case .performance(let item): item.id
        case .custom(let item): item.id
        }
    }

    case navigation(NavigationToolItem)
    case toggle(ToggleToolItem)
    case customInfo(CustomInfoTool.Item)
    case performance(PerformanceInfoItem)
    case custom(any CustomToolTableItem)
}
