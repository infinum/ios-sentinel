//
//  ZipHandler.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 13.03.2025..
//

import Foundation

enum CreateZipError: Error {
    case urlNotADirectory(URL)
    case failedToCreateZIP(Error)
}

enum ZipHandler {

    static func createZip(zipFinalURL: URL, fromDirectory directoryURL: URL, databaseURL: URL) throws -> URL {
        // Copy the database file into the export directory
        let newDatabaseFileURL = directoryURL.appendingPathComponent(databaseURL.lastPathComponent)
        try FileManager.default.copyItem(at: databaseURL, to: newDatabaseFileURL)

        guard directoryURL.isDirectory else {
            throw CreateZipError.urlNotADirectory(directoryURL)
        }

        var fileManagerError: Error?
        var coordinatorError: NSError?
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(
            readingItemAt: directoryURL,
            options: .forUploading,
            error: &coordinatorError
        ) { zipCreatedURL in
            do {
                try FileManager.default.moveItem(at: zipCreatedURL, to: zipFinalURL)
            } catch {
                fileManagerError = error
            }
        }
        if let error = coordinatorError ?? fileManagerError {
            throw CreateZipError.failedToCreateZIP(error)
        }
        return zipFinalURL
    }
}

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
