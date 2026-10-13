//
//  APIMockStoring.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// What the API mocking screens need from the mocks they show: the app's own ``APIMockStore``, or Sentinel
/// for Mac's copy of a device's mocks, which forwards every change to the device.
protocol APIMockStoring: ObservableObject {

    /// Mocks the app passed to the tool, in the order they were given.
    var appMocks: [APIMock] { get }
    /// Mocks made in the tool.
    var localMocks: [APIMock] { get }
    var enabledIDs: Set<String> { get }
    /// The master switch: while it's off, no mock answers.
    var isMockingEnabled: Bool { get }
    /// `false` while changes can't reach the mocks, as while Sentinel for Mac is disconnected from the device.
    var isEditable: Bool { get }

    /// Why the mock can't answer as intended, or `nil` when it can.
    func warning(for mock: APIMock) -> String?
    /// Switching a mock on switches off the mocks that answer the same requests.
    func setEnabled(_ isEnabled: Bool, for mock: APIMock)
    func setMockingEnabled(_ isEnabled: Bool)
    /// Adds the mock, or replaces the local mock with the same id.
    func save(_ mock: APIMock)
    func delete(_ mock: APIMock)
}

extension APIMockStoring {

    /// Mocks that answer requests, in the order they're tried: local mocks first, as testers make them to
    /// override what the app ships with.
    var activeMocks: [APIMock] {
        guard isMockingEnabled else { return [] }
        return (localMocks + appMocks).filter(isEnabled)
    }

    func isEnabled(_ mock: APIMock) -> Bool {
        enabledIDs.contains(mock.id)
    }
}
