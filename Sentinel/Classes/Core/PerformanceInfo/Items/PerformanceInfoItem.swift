//
//  PerformanceInfoItem.swift
//  Sentinel
//
//  Created by Nikola Majcen on 18/11/2020.
//

import Foundation

public struct PerformanceInfoItem {

    // MARK: - Internal properties

    let title: String
    let valueDidChange: () -> String

    // MARK: - Lifecycle

    init(title: String, valueDidChange: @escaping () -> String) {
        self.title = title
        self.valueDidChange = valueDidChange
    }
}

// MARK: - Equatable conformance

extension PerformanceInfoItem: Equatable {

    public static func == (lhs: PerformanceInfoItem, rhs: PerformanceInfoItem) -> Bool {
        lhs.title == rhs.title
    }
}

// MARK: - Identifiable conformance

extension PerformanceInfoItem: Identifiable {

    public var id: String {
        title
    }
}
