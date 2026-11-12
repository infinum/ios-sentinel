//
//  FileSystemCleaner.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import Foundation

#if os(iOS)

/// Removes the contents of the app container directories.
enum FileSystemCleaner {

    static func url(for directory: FileManager.SearchPathDirectory) -> URL? {
        FileManager.default.urls(for: directory, in: .userDomainMask).first
    }

    static var temporaryDirectoryURL: URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    /// Deletes everything inside `url`, keeping the directory itself.
    ///
    /// Each entry is removed on its own so that a single undeletable item doesn't abort the sweep.
    /// Hidden files are included — a freshly installed app has none of those either.
    ///
    /// - Parameters:
    ///   - excluding: Names of entries to leave untouched.
    ///   - systemManagedItems: Names of entries the OS keeps to itself. Failing to delete one of
    ///     these is reported as a warning rather than a failure.
    static func clearContents(
        of url: URL,
        step: ClearAppDataStep,
        excluding: Set<String> = [],
        systemManagedItems: Set<String> = []
    ) -> [ClearAppDataFailure] {
        let fileManager = FileManager.default
        let contents: [URL]
        do {
            contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: []
            )
        } catch {
            // A missing directory is not a failure: there was nothing to clear.
            guard fileManager.fileExists(atPath: url.path) else { return [] }
            return [ClearAppDataFailure(step: step, reason: error.localizedDescription)]
        }

        return contents
            .filter { !excluding.contains($0.lastPathComponent) }
            .compactMap { item in
                do {
                    try fileManager.removeItem(at: item)
                    return nil
                } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError {
                    // Deleted by its owner after the listing, e.g. SQLite's temporary files in `tmp`.
                    return nil
                } catch {
                    return failure(
                        for: error,
                        step: step,
                        item: item.lastPathComponent,
                        isSystemManaged: systemManagedItems.contains(item.lastPathComponent)
                    )
                }
            }
    }
}

// MARK: - Helpers

private extension FileSystemCleaner {

    /// Only a permission error on a known OS-owned entry is downgraded to a warning. The same error
    /// anywhere else means user data is still on disk, so it stays a failure.
    static func failure(
        for error: Error,
        step: ClearAppDataStep,
        item: String,
        isSystemManaged: Bool
    ) -> ClearAppDataFailure {
        let error = error as NSError
        let isSkipped = isSystemManaged
            && error.domain == NSCocoaErrorDomain
            && (error.code == NSFileWriteNoPermissionError || error.code == NSFileWriteUnknownError)

        return ClearAppDataFailure(
            step: step,
            item: item,
            reason: isSkipped ? "skipped (system-managed)" : error.localizedDescription,
            kind: isSkipped ? .warning : .failed
        )
    }
}

#endif
