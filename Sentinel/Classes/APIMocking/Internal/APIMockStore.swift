//
//  APIMockStore.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Holds the mocks and which of them are switched on, saves them, and tells the matcher which mocks
/// answer requests. Used from the main thread.
final class APIMockStore: APIMockStoring {

    static let shared = APIMockStore(
        persistence: APIMockPersistence(fileURL: APIMockPersistence.defaultFileURL),
        matcher: APIMockMatcher.shared
    )

    // MARK: - Internal properties

    @Published private(set) var appMocks: [APIMock] = []
    @Published private(set) var localMocks: [APIMock]
    @Published private(set) var enabledIDs: Set<String>
    @Published private(set) var isMockingEnabled: Bool
    let isEditable = true

    // MARK: - Private properties

    private let persistence: APIMockPersistence
    private let matcher: APIMockMatcher

    private var allMocks: [APIMock] {
        localMocks + appMocks
    }

    // MARK: - Lifecycle

    init(persistence: APIMockPersistence, matcher: APIMockMatcher) {
        self.persistence = persistence
        self.matcher = matcher
        let state = persistence.load()
        isMockingEnabled = state.isMockingEnabled
        enabledIDs = state.enabledIDs
        localMocks = state.localMocks
        matcher.update(activeMocks: activeMocks)
    }
}

// MARK: - App mocks

extension APIMockStore {

    func setAppMocks(_ mocks: [APIMock]) {
        var ids = Set<String>()
        appMocks = mocks.filter { mock in
            guard ids.insert(mock.id).inserted else {
                NSLog("Sentinel API mocking ignores a second mock with the id \"%@\". Give each mock a unique name or id.", mock.id)
                return false
            }
            return true
        }
        matcher.update(activeMocks: activeMocks)
    }
}

// MARK: - Looking mocks up

extension APIMockStore {

    func mock(withID id: String) -> APIMock? {
        allMocks.first { $0.id == id }
    }

    func warning(for mock: APIMock) -> String? {
        mock.warning
    }
}

// MARK: - Switching mocks on and off

extension APIMockStore {

    func setEnabled(_ isEnabled: Bool, for mock: APIMock) {
        if isEnabled {
            switchOffMocks(sharingEndpointWith: mock)
            enabledIDs.insert(mock.id)
        } else {
            enabledIDs.remove(mock.id)
        }
        didChange()
    }

    func setMockingEnabled(_ isEnabled: Bool) {
        isMockingEnabled = isEnabled
        didChange()
    }
}

// MARK: - Local mocks

extension APIMockStore {

    func isLocal(_ mock: APIMock) -> Bool {
        localMocks.contains { $0.id == mock.id }
    }

    func save(_ mock: APIMock) {
        if let index = localMocks.firstIndex(where: { $0.id == mock.id }) {
            localMocks[index] = mock
        } else {
            localMocks.append(mock)
        }
        // The edit may have moved an enabled mock onto an endpoint another enabled mock answers.
        if isEnabled(mock) {
            switchOffMocks(sharingEndpointWith: mock)
        }
        didChange()
    }

    func delete(_ mock: APIMock) {
        localMocks.removeAll { $0.id == mock.id }
        enabledIDs.remove(mock.id)
        didChange()
    }
}

// MARK: - Helpers

private extension APIMockStore {

    func switchOffMocks(sharingEndpointWith mock: APIMock) {
        allMocks
            .filter { $0.sharesEndpoint(with: mock) }
            .forEach { enabledIDs.remove($0.id) }
    }

    func didChange() {
        matcher.update(activeMocks: activeMocks)
        persistence.save(
            APIMockPersistence.State(
                isMockingEnabled: isMockingEnabled,
                enabledIDs: enabledIDs,
                localMocks: localMocks
            )
        )
    }
}
