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
