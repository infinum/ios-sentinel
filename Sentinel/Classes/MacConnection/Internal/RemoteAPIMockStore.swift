//
//  RemoteAPIMockStore.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Sentinel Companion's copy of a device's API mocks, shown with the same screens as on the device.
///
/// The device stays in charge: every change is sent to it as a command, and the copy changes only when the
/// device sends back its new mocks and switches. Used from the main thread.
final class RemoteAPIMockStore: APIMockStoring {

    @Published private(set) var appMocks: [APIMock] = []
    @Published private(set) var localMocks: [APIMock] = []
    @Published private(set) var enabledIDs: Set<String> = []
    @Published private(set) var isMockingEnabled = true
    /// Off while the device is disconnected, as changes would go nowhere.
    @Published var isEditable = false

    private let send: (RemoteMockCommand) -> Void
    private var warnings: [String: String] = [:]

    init(send: @escaping (RemoteMockCommand) -> Void) {
        self.send = send
    }

    // MARK: - Updates from the device

    func apply(_ mocks: [RemoteMock]) {
        var appMocks: [APIMock] = []
        var localMocks: [APIMock] = []
        var warnings: [String: String] = [:]
        for remoteMock in mocks {
            guard let mock = try? remoteMock.makeAPIMock() else {
                // A newer device may use a method or error this version doesn't know.
                NSLog("Sentinel Companion skips the mock \"%@\", which it can't read.", remoteMock.name)
                continue
            }
            warnings[mock.id] = remoteMock.warning
            if remoteMock.isLocal {
                localMocks.append(mock)
            } else {
                appMocks.append(mock)
            }
        }
        self.warnings = warnings
        self.appMocks = appMocks
        self.localMocks = localMocks
    }

    func apply(_ switches: RemoteMockSwitches) {
        isMockingEnabled = switches.isMockingEnabled
        enabledIDs = Set(switches.enabledIDs)
    }

    // MARK: - APIMockStoring

    func warning(for mock: APIMock) -> String? {
        warnings[mock.id]
    }

    func setEnabled(_ isEnabled: Bool, for mock: APIMock) {
        send(RemoteMockCommand.setEnabled(id: mock.id, isEnabled: isEnabled))
    }

    func setMockingEnabled(_ isEnabled: Bool) {
        send(RemoteMockCommand.setMockingEnabled(isEnabled))
    }

    func save(_ mock: APIMock) {
        send(RemoteMockCommand.save(RemoteMock(mock: mock, isLocal: true)))
    }

    func delete(_ mock: APIMock) {
        send(RemoteMockCommand.delete(id: mock.id))
    }
}
