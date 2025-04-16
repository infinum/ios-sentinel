//
//  ArchiveHandler.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 13.03.2025..
//

import Foundation

enum CreateArchiveError: Error {
    case urlNotADirectory(URL)
    case failedToCreateArchive(Error)
}

enum ArchiveHandler {

    static func createArchive(archiveDestinationURL: URL, fromDirectory directoryURL: URL, databaseURL: URL) throws -> URL {
        // Copy the database file into the export directory
        let newDatabaseFileURL = directoryURL.appendingPathComponent(databaseURL.lastPathComponent)
        try FileManager.default.copyItem(at: databaseURL, to: newDatabaseFileURL)

        guard directoryURL.isDirectory else {
            throw CreateArchiveError.urlNotADirectory(directoryURL)
        }

        var fileManagerError: Error?
        var coordinatorError: NSError?
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(
            readingItemAt: directoryURL,
            options: .forUploading,
            error: &coordinatorError
        ) { archiveCreatedURL in
            do {
                try FileManager.default.moveItem(at: archiveCreatedURL, to: archiveDestinationURL)
            } catch {
                fileManagerError = error
            }
        }
        if let error = coordinatorError ?? fileManagerError {
            throw CreateArchiveError.failedToCreateArchive(error)
        }
        return archiveDestinationURL
    }
}

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
