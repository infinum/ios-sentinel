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
    private let databaseFileName: String

    // MARK: - Lifecycle

    init(fileManager: FileManager = .default, databaseFileName: String) {
        self.fileManager = fileManager
        self.databaseFileName = databaseFileName
    }

    private lazy var documentDirectoryUrl: URL? = {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }()

    private lazy var exportDirectoryUrl: URL? = {
        documentDirectoryUrl?.appendingPathComponent("export")
    }()

    private lazy var exportArchiveUrl: URL? = {
        exportDirectoryUrl?.appendingPathComponent("export.zip")
    }()

    private lazy var databaseURL: URL? = {
        guard let documentDirectoryUrl else { return nil }
        return URL(fileURLWithPath: "\(documentDirectoryUrl.path)/\(databaseFileName)")
    }()

    func importDatabase(from url: URL) throws {
        defer { url.stopAccessingSecurityScopedResource() }
        guard
            let databaseURL,
            url.startAccessingSecurityScopedResource()
        else { return }

        _ = try fileManager.replaceItemAt(databaseURL, withItemAt: url)
    }

    func exportDatabase() -> URL? {
        guard
            let exportDirectoryUrl,
            let databaseURL,
            let exportArchiveUrl
        else { return nil }

        deleteDirectoryIfExists(atPath: exportDirectoryUrl.path)
        createDirectoryIfNeeded(atPath: exportDirectoryUrl.path)

        return try? ZipHandler.createZip(
            zipFinalURL: exportArchiveUrl,
            fromDirectory: exportDirectoryUrl,
            databaseURL: databaseURL
        )
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
