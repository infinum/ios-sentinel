//
//  AppDataCleaner.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

#if os(iOS)

import Foundation

/// Runs every clearing step and collects what went wrong.
enum AppDataCleaner {

    private static let queue = DispatchQueue(label: "com.infinum.sentinel.clearAppData", qos: .userInitiated)
    private static let webKitTimeout = DispatchTimeInterval.seconds(10)

    /// Clears the app's persisted data, reporting the outcome on the main queue.
    ///
    /// The framework level clears run before the directory sweep, so that URL loading, cookie
    /// storage and WebKit remove their own backing files first. Sweeping the directories first
    /// would only let them write those files straight back out, so the sweep waits for WebKit.
    ///
    /// - Warning: Must be called from the main queue.
    static func clearAll(completion: @escaping (ClearAppDataReport) -> Void) {
        dispatchPrecondition(condition: .onQueue(.main))

        // Both post change notifications and KVO on the calling thread, and the host app's
        // `@AppStorage` and other observers expect those on main.
        let mainQueueFailures = WebDataCleaner.clearCookies() + UserDefaultsCleaner.clear()

        WebDataCleaner.clearWebsiteData(timeout: webKitTimeout) { websiteDataFailures in
            queue.async {
                WebDataCleaner.clearURLCache()
                let failures = mainQueueFailures
                    + websiteDataFailures
                    + KeychainCleaner.clear()
                    + clearDirectories()
                DispatchQueue.main.async { completion(ClearAppDataReport(failures: failures)) }
            }
        }
    }
}

// MARK: - Helpers

private extension AppDataCleaner {

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

#endif
