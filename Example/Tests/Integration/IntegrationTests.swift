//
//  IntegrationTests.swift
//  Sentinel_Tests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing

/// Parent of every hosted integration suite.
///
/// These suites share the host app's Documents directory, `UserDefaults.standard`, the Keychain,
/// `Sentinel.shared` and process-wide handlers, so `.serialized` here makes all of them run one at a time.
@Suite("Integration", .serialized)
struct IntegrationTests {}

/// Polls `condition` every 100 ms for up to five seconds, then expects it to hold.
///
/// Waiting only as long as needed keeps tests fast, and the long upper bound keeps them steady on a
/// slow simulator, where animations and asynchronous callbacks can take a while.
@MainActor
func waitUntil(_ condition: () -> Bool) async throws {
    for _ in 0..<50 where !condition() {
        try await Task.sleep(nanoseconds: 100_000_000)
    }
    #expect(condition())
}
