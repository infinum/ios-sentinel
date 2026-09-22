//
//  FileSystemCleaner.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import Foundation

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
    static func clearContents(of url: URL, step: ClearAppDataStep) -> [ClearAppDataFailure] {
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

        return contents.compactMap { item in
            do {
                try fileManager.removeItem(at: item)
                return nil
            } catch {
                return failure(for: error, step: step, item: item.lastPathComponent)
            }
        }
    }
}

// MARK: - Helpers

private extension FileSystemCleaner {

    /// The OS keeps some container subdirectories to itself, `Caches/Snapshots` being the usual one.
    /// Those are reported as skipped rather than failed.
    static func failure(for error: Error, step: ClearAppDataStep, item: String) -> ClearAppDataFailure {
        let error = error as NSError
        let isSystemManaged = error.domain == NSCocoaErrorDomain
            && (error.code == NSFileWriteNoPermissionError || error.code == NSFileWriteUnknownError)

        return ClearAppDataFailure(
            step: step,
            item: item,
            reason: error.localizedDescription,
            kind: isSystemManaged ? .skipped : .failed
        )
    }
}
