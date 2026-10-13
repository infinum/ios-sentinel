//
//  RemoteMockBridge.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Combine
import Foundation

/// The device's side of API mocking over the Mac connection: sends Sentinel Companion the mocks and switches
/// as they change, and makes the changes it asks for. Used from the main thread, like the store.
final class RemoteMockBridge {

    private let store: APIMockStore
    private var subscriptions: Set<AnyCancellable> = []

    /// Sends the current mocks and switches at once, then again whenever they change.
    init(store: APIMockStore, send: @escaping (RemoteMessage) -> Void) {
        self.store = store
        // `@Published` publishes before the property changes, so the values come from the publishers.
        // Switches go apart from the mocks, as building the mocks reads body files from disk.
        store.$appMocks
            .combineLatest(store.$localMocks)
            .sink { appMocks, localMocks in
                send(.mocks(RemoteMock.list(appMocks: appMocks, localMocks: localMocks)))
            }
            .store(in: &subscriptions)
        store.$isMockingEnabled
            .combineLatest(store.$enabledIDs)
            .sink { isMockingEnabled, enabledIDs in
                send(.mockSwitches(RemoteMockSwitches(isMockingEnabled: isMockingEnabled, enabledIDs: enabledIDs.sorted())))
            }
            .store(in: &subscriptions)
    }

    func apply(_ command: RemoteMockCommand) {
        switch command {
        case .setMockingEnabled(let isEnabled):
            store.setMockingEnabled(isEnabled)
        case .setEnabled(let id, let isEnabled):
            guard let mock = store.mock(withID: id) else { return }
            store.setEnabled(isEnabled, for: mock)
        case .save(let remoteMock):
            // Mocks the app ships with can't be changed, only copied into new local mocks.
            guard let mock = try? remoteMock.makeAPIMock(), !store.appMocks.contains(where: { $0.id == mock.id }) else {
                return
            }
            store.save(mock)
        case .delete(let id):
            guard let mock = store.localMocks.first(where: { $0.id == id }) else { return }
            store.delete(mock)
        }
    }
}
