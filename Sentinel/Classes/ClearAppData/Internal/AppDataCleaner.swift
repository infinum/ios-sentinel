//
//  AppDataCleaner.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import Foundation

/// Runs every clearing step and collects what went wrong.
enum AppDataCleaner {

    private static let queue = DispatchQueue(label: "com.infinum.sentinel.clearAppData", qos: .userInitiated)
    private static let webKitTimeout = DispatchTimeInterval.seconds(10)

    /// Clears the app's persisted data, reporting the outcome on the main queue.
    static func clearAll(completion: @escaping (ClearAppDataReport) -> Void) {
        queue.async {
            let failures = clearAllSteps()
            DispatchQueue.main.async { completion(ClearAppDataReport(failures: failures)) }
        }
    }
}

// MARK: - Helpers

private extension AppDataCleaner {

    /// The framework level clears run first so that URL loading, cookie storage and WebKit remove
    /// their own backing files. Sweeping the directories first would only let them write those
    /// files straight back out.
    static func clearAllSteps() -> [ClearAppDataFailure] {
        var failures: [ClearAppDataFailure] = []

        WebDataCleaner.clearURLCache()
        failures += WebDataCleaner.clearCookies()
        failures += WebDataCleaner.clearWebsiteData(timeout: webKitTimeout)
        failures += KeychainCleaner.clear()
        failures += UserDefaultsCleaner.clear()
        failures += clearDirectories()

        return failures
    }

    /// Caches before Documents, so the cheap wins land even if a live database file in Documents
    /// causes trouble.
    static func clearDirectories() -> [ClearAppDataFailure] {
        var failures = FileSystemCleaner.clearContents(
            of: FileSystemCleaner.temporaryDirectoryURL,
            step: .temporaryDirectory
        )

        let directories: [(FileManager.SearchPathDirectory, ClearAppDataStep)] = [
            (.cachesDirectory, .cachesDirectory),
            (.applicationSupportDirectory, .applicationSupportDirectory),
            (.documentDirectory, .documentsDirectory)
        ]

        for (directory, step) in directories {
            guard let url = FileSystemCleaner.url(for: directory) else {
                failures.append(ClearAppDataFailure(step: step, reason: "directory not found"))
                continue
            }
            failures += FileSystemCleaner.clearContents(of: url, step: step)
        }

        return failures
    }
}
