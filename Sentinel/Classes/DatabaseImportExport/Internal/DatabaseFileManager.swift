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

    init(fileManager: FileManager, databaseFileName: String) {
        self.fileManager = fileManager
        self.databaseFileName = databaseFileName
    }

    private lazy var documentDirectoryUrl: URL = {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()

    private lazy var exportDirectoryUrl: URL = {
        documentDirectoryUrl.appendingPathComponent("export")
    }()

    private lazy var exportArchiveUrl: URL = {
        exportDirectoryUrl.appendingPathComponent("export.zip")
    }()

    func importDatabase(from url: URL) throws {
        defer { url.stopAccessingSecurityScopedResource() }
        guard url.startAccessingSecurityScopedResource() else { return }
//        let tempDirectory = fileManager.temporaryDirectory
//        let tempPath = tempDirectory.path + "/" + url.lastPathComponent
//        let tempURL = URL(fileURLWithPath: tempPath)
        let databaseURL = URL(fileURLWithPath: "\(documentDirectoryUrl.path)/\(databaseFileName)")
        deleteDirectoryIfExists(atPath: databaseURL.path)
//        createDirectoryIfNeeded(atPath: databaseURL.path)
        try fileManager.copyItem(at: url, to: databaseURL)
        print("!!!here")
    }

    func exportDatabase() -> URL {
        deleteDirectoryIfExists(atPath: exportDirectoryUrl.path)
        createDirectoryIfNeeded(atPath: exportDirectoryUrl.path)

        let databaseURL = URL(fileURLWithPath: "\(documentDirectoryUrl.path)/\(databaseFileName)")
//        createDirectoryIfNeeded(atPath: databaseURL.path)



//        try? fileManager.copyItem(atPath: "\(documentDirectoryUrl.path)/\(databaseFileName)", toPath: databaseURL.path)
        let zip = try? createZipAtTmp(zipFilename: "new_archive", filesToZip: [.existingFile(databaseURL)])
        return zip ?? .init(string: "www.google.com")!
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

    enum CreateZipError: Swift.Error {
        case urlNotADirectory(URL)
        case failedToCreateZIP(Swift.Error)
    }

    func createZip(
        zipFinalURL: URL,
        fromDirectory directoryURL: URL
    ) throws -> URL {
        // see URL extension below
        guard directoryURL.isDirectory else {
            throw CreateZipError.urlNotADirectory(directoryURL)
        }

        var fileManagerError: Swift.Error?
        var coordinatorError: NSError?
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(
            readingItemAt: directoryURL,
            options: .forUploading,
            error: &coordinatorError
        ) { zipCreatedURL in
            do {
                // will fail if file already exists at finalURL
                // use `replaceItem` instead if you want "overwrite" behavior
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

    func createZipAtTmp(
        zipFilename: String,
        zipExtension: String = "zip",
        fromDirectory directoryURL: URL
    ) throws -> URL {
//        let /*finalURL = FileManager.default.temporaryDirectory.appendingPathComponent(zipFilename).appendingPathExtension(zipExtension)*/
        return try createZip(
            zipFinalURL: exportArchiveUrl,
            fromDirectory: directoryURL
        )
    }

    func createZipAtTmp(
        zipFilename: String,
        zipExtension: String = "zip",
        filesToZip: [FileToZip]
    ) throws -> URL {
//        let directoryToZipURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent(zipFilename).path(path: UUID().uuidString).appending(path: zipFilename)
//        try FileManager.default.createDirectory(at: exportArchiveUrl, withIntermediateDirectories: true, attributes: [:])
        for fileToZip in filesToZip {
            try fileToZip.prepareInDirectory(directoryURL: exportDirectoryUrl)
        }
        return try createZipAtTmp(
            zipFilename: zipFilename,
            zipExtension: zipExtension,
            fromDirectory: exportDirectoryUrl
        )
    }
}

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

enum FileToZip {
    case data(Data, filename: String)
    case existingFile(URL)
    case renamedFile(URL, toFilename: String)
}

extension FileToZip {
    func prepareInDirectory(directoryURL: URL) throws {
        switch self {
        case .data(let data, filename: let filename):
            let fileURL = directoryURL.appendingPathComponent(filename)
            try data.write(to: fileURL)
        case .existingFile(let existingFileURL):
            let filename = existingFileURL.lastPathComponent
            let newFileURL = directoryURL.appendingPathComponent(filename)
            try FileManager.default.copyItem(at: existingFileURL, to: newFileURL)
        case .renamedFile(let existingFileURL, toFilename: let filename):
            let newFileURL = directoryURL.appendingPathComponent(filename)
            try FileManager.default.copyItem(at: existingFileURL, to: newFileURL)
        }
    }
}
