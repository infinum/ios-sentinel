//
//  DatabaseFileManager.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 12.03.2025..
//

import Foundation

public enum DatabaseFileError: Error {
    case importFailed
    case exportFailed
}

final class DatabaseFileManager {

    // MARK: - Private properties

    private let fileManager: FileManager
    private let databaseURL: URL

    // MARK: - Lifecycle

    init(fileManager: FileManager, databaseURL: URL) {
        self.fileManager = fileManager
        self.databaseURL = databaseURL
    }

    func importDatabase(from url: URL) throws {
        deleteDirectoryIfExists(atPath: databaseURL.path)
        createDirectoryIfNeeded(atPath: databaseURL.path)
        try moveFile(from: url, to: databaseURL)
    }
}

private extension DatabaseFileManager {

    func moveFile(from fromUrl: URL, to toURL: URL) throws {
        try fileManager.moveItem(at: fromUrl, to: toURL)
    }

    func createDirectoryIfNeeded(atPath path: String) {
        if !fileManager.fileExists(atPath: path) {
            try? fileManager.createDirectory(
                atPath: path,
                withIntermediateDirectories: true
            )
        }
    }

    func deleteDirectoryIfExists(atPath path: String) {
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
    }
}
