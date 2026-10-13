//
//  APIMockListEntry.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// One row of the mock list: a mock on its own, or a collapsible group of the mocks sharing a group name.
enum APIMockListEntry: Identifiable, Equatable {

    case mock(APIMock)
    case group(name: String, mocks: [APIMock])

    var id: String {
        switch self {
        case .mock(let mock): return "mock.\(mock.id)"
        case .group(let name, _): return "group.\(name)"
        }
    }

    /// The mocks in their given order, each group listed where its first mock is.
    static func entries(for mocks: [APIMock]) -> [APIMockListEntry] {
        var groupedMocks: [String: [APIMock]] = [:]
        var order: [String?] = []
        var ungrouped: [APIMock] = []

        for mock in mocks {
            guard let group = mock.groupName else {
                ungrouped.append(mock)
                order.append(nil)
                continue
            }
            if groupedMocks[group] == nil {
                order.append(group)
            }
            groupedMocks[group, default: []].append(mock)
        }

        var remainingUngrouped = ungrouped[...]
        return order.compactMap { group in
            guard let group else {
                return remainingUngrouped.popFirst().map(APIMockListEntry.mock)
            }
            return APIMockListEntry.group(name: group, mocks: groupedMocks[group] ?? [])
        }
    }
}

extension APIMock {

    /// The group name, or `nil` when it's missing or blank.
    var groupName: String? {
        guard let group = group?.trimmingCharacters(in: .whitespacesAndNewlines), !group.isEmpty else {
            return nil
        }
        return group
    }
}
