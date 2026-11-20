//
//  UserDefaultsCleaner.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import Foundation

#if os(iOS)

/// Removes the app's persisted user defaults, including any suites it created.
enum UserDefaultsCleaner {

    static func clear() -> [ClearAppDataFailure] {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return [ClearAppDataFailure(step: .userDefaults, reason: "Missing bundle identifier")]
        }

        let defaults = UserDefaults.standard
        // `synchronize()` is deliberately not called: it has been deprecated since iOS 12 and
        // `removePersistentDomain(forName:)` is already durable.
        defaults.removePersistentDomain(forName: bundleIdentifier)

        suiteNames()
            .filter { $0 != bundleIdentifier }
            .forEach { defaults.removePersistentDomain(forName: $0) }

        return []
    }
}

// MARK: - Helpers

private extension UserDefaultsCleaner {

    /// Suites created with `UserDefaults(suiteName:)` are backed by their own plist inside the
    /// container, so they can be discovered by listing `Library/Preferences`.
    ///
    /// The plists are cleared through `removePersistentDomain(forName:)` rather than deleted,
    /// because `cfprefsd` caches them in memory and would write them back out.
    ///
    /// App group suites live outside the container and are not reachable this way — the group
    /// identifiers are only declared in the host app's entitlements.
    static func suiteNames() -> [String] {
        guard let preferencesURL = FileSystemCleaner.url(for: .libraryDirectory)?
            .appendingPathComponent("Preferences", isDirectory: true) else { return [] }

        let contents = try? FileManager.default.contentsOfDirectory(
            at: preferencesURL,
            includingPropertiesForKeys: nil,
            options: []
        )

        return (contents ?? [])
            .filter { $0.pathExtension == "plist" }
            .map { $0.deletingPathExtension().lastPathComponent }
            .filter { !$0.hasPrefix("com.apple.") && $0 != ".GlobalPreferences" }
    }
}

#endif
