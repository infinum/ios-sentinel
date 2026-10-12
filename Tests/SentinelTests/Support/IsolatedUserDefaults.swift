//
//  IsolatedUserDefaults.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation

/// A throwaway `UserDefaults` suite, so tests running in parallel never share keys.
/// The suite is removed when the instance is deallocated.
final class IsolatedUserDefaults {

    let suiteName = "com.infinum.sentinel.tests.\(UUID().uuidString)"
    let defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: suiteName)!
    }

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
    }
}
