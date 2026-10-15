//
//  APIMockStore.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Holds the mocks and which of them are switched on, saves them, and tells the matcher which mocks
/// answer requests. Used from the main thread.
final class APIMockStore: ObservableObject {

    static let shared = APIMockStore(
        persistence: APIMockPersistence(fileURL: APIMockPersistence.defaultFileURL),
        matcher: APIMockMatcher.shared
    )

    // MARK: - Internal properties

    /// Mocks the app passed to the tool, in the order they were given.
    @Published private(set) var appMocks: [APIMock] = []
    /// Mocks made in the tool.
    @Published private(set) var localMocks: [APIMock]
    @Published private(set) var enabledIDs: Set<String>
    /// The master switch: while it's off, no mock answers.
    @Published private(set) var isMockingEnabled: Bool

    /// Mocks that answer requests, in the order they're tried: local mocks first, as testers make them to
    /// override what the app ships with.
    var activeMocks: [APIMock] {
        guard isMockingEnabled else { return [] }
        return allMocks.filter { enabledIDs.contains($0.id) }
    }

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

// MARK: - Switching mocks on and off

extension APIMockStore {

    func isEnabled(_ mock: APIMock) -> Bool {
        enabledIDs.contains(mock.id)
    }

    /// Switching a mock on switches off the mocks that answer the same requests.
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

    /// Adds the mock, or replaces the local mock with the same id.
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
