//
//  CustomToolTableItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 13.12.2024..
//

import SwiftUI

public protocol CustomToolTableItem: Identifiable, Equatable {
    var title: String { get }
    @ViewBuilder var content: any View { get }
}

public extension CustomToolTableItem {
    var id: String { title }
}
