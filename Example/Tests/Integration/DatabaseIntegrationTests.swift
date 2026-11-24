//
//  DatabaseIntegrationTests.swift
//  Sentinel_Tests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
import UniformTypeIdentifiers
@testable import Sentinel

extension IntegrationTests {

    /// `DatabaseFileManager` always works inside the Documents directory, so this runs in the host app's sandbox.
    @Suite("Database export")
    final class DatabaseIntegrationTests {

        private let databaseName = "sentinel-tests-\(UUID().uuidString).sqlite"
        private let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        private var databaseURL: URL { documents.appendingPathComponent(databaseName) }
        private var exportDirectory: URL { documents.appendingPathComponent("export", isDirectory: true) }

        init() throws {
            try Data("database contents".utf8).write(to: databaseURL)
        }

        deinit {
            try? FileManager.default.removeItem(at: databaseURL)
            try? FileManager.default.removeItem(at: exportDirectory)
        }

        @Test("Exporting copies the database into the export directory")
        func exportCopy() throws {
            let manager = DatabaseFileManager(databaseFilePath: databaseName)

            let exported = try #require(manager.exportDatabase(asArchive: false))

            #expect(exported == exportDirectory.appendingPathComponent(databaseName))
            #expect(try Data(contentsOf: exported) == Data("database contents".utf8))
        }

        @Test("Exporting as an archive creates export.zip")
        func exportArchive() throws {
            let manager = DatabaseFileManager(databaseFilePath: databaseName)

            let exported = try #require(manager.exportDatabase(asArchive: true))

            #expect(exported.lastPathComponent == "export.zip")
            #expect(try Data(contentsOf: exported).prefix(4) == Data([0x50, 0x4B, 0x03, 0x04]))
        }

        @Test("Every export starts from an empty export directory")
        func exportDirectoryIsRecreated() throws {
            try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
            try Data("stale".utf8).write(to: exportDirectory.appendingPathComponent("stale.txt"))
            let manager = DatabaseFileManager(databaseFilePath: databaseName)

            _ = manager.exportDatabase(asArchive: false)

            #expect(try FileManager.default.contentsOfDirectory(atPath: exportDirectory.path) == [databaseName])
        }

        @Test("Exporting a missing database returns nil")
        func exportMissingDatabase() {
            let manager = DatabaseFileManager(databaseFilePath: "missing-\(UUID().uuidString).sqlite")

            #expect(manager.exportDatabase(asArchive: false) == nil)
        }

        @Test("Importing replaces the database with the picked file")
        func importReplacesDatabase() throws {
            let source = FileManager.default.temporaryDirectory.appendingPathComponent("import-\(UUID().uuidString).sqlite")
            try Data("imported".utf8).write(to: source)
            defer { try? FileManager.default.removeItem(at: source) }
            let manager = DatabaseFileManager(databaseFilePath: databaseName)

            try manager.importDatabase(from: source)

            #expect(try Data(contentsOf: databaseURL) == Data("imported".utf8))
            #expect(FileManager.default.fileExists(atPath: source.path))
        }

        @Test("The view model imports the picked file")
        func viewModelImport() throws {
            let source = FileManager.default.temporaryDirectory.appendingPathComponent("import-\(UUID().uuidString).sqlite")
            try Data("from view model".utf8).write(to: source)
            defer { try? FileManager.default.removeItem(at: source) }
            let viewModel = DatabaseViewModel(
                databaseFilePath: databaseName,
                allowedTypes: [.database],
                exportAsArchive: false
            )

            viewModel.importDatabase(url: source)

            #expect(try Data(contentsOf: databaseURL) == Data("from view model".utf8))
        }

        @Test("The view model publishes the exported URL")
        func viewModelExport() {
            let viewModel = DatabaseViewModel(
                databaseFilePath: databaseName,
                allowedTypes: [.database],
                exportAsArchive: false
            )

            viewModel.exportDatabase()

            #expect(viewModel.selectedURL?.lastPathComponent == databaseName)
            #expect(viewModel.allowedTypes == [.database])
        }
    }
}
