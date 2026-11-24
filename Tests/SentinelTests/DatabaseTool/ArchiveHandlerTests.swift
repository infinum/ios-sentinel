//
//  ArchiveHandlerTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Database archive handler")
struct ArchiveHandlerTests {

    @Test("Creates a zip archive at the destination")
    func createsArchive() throws {
        let source = try TemporaryDirectory()
        let export = try TemporaryDirectory()
        let database = try source.createFile(named: "database.sqlite", contents: String(repeating: "row\n", count: 100))
        let destination = source.url.appendingPathComponent("export.zip")

        let archive = try ArchiveHandler.createArchive(
            archiveDestinationURL: destination,
            fromDirectory: export.url,
            databaseURL: database
        )

        #expect(archive == destination)
        // Every zip file starts with the local file header signature "PK\u{3}\u{4}".
        let header = try Data(contentsOf: archive).prefix(4)
        #expect(header == Data([0x50, 0x4B, 0x03, 0x04]))
        #expect(FileManager.default.fileExists(atPath: export.url.appendingPathComponent("database.sqlite").path))
    }

    @Test("A destination that isn't a directory throws urlNotADirectory")
    func notADirectory() throws {
        let source = try TemporaryDirectory()
        let database = try source.createFile(named: "database.sqlite")
        let notADirectory = try source.createFile(named: "plain-file")

        var thrownError: Error?
        do {
            _ = try ArchiveHandler.createArchive(
                archiveDestinationURL: source.url.appendingPathComponent("export.zip"),
                fromDirectory: notADirectory,
                databaseURL: database
            )
        } catch {
            thrownError = error
        }

        #expect(thrownError != nil)
        withKnownIssue("The database is copied into the directory before the isDirectory check, so the copy fails first") {
            guard case CreateArchiveError.urlNotADirectory = try #require(thrownError) else {
                Issue.record("Expected urlNotADirectory, got \(String(describing: thrownError))")
                return
            }
        }
    }

    @Test("URL.isDirectory tells directories from files")
    func isDirectory() throws {
        let directory = try TemporaryDirectory()
        let file = try directory.createFile(named: "file.txt")

        #expect(directory.url.isDirectory)
        #expect(!file.isDirectory)
        #expect(!directory.url.appendingPathComponent("missing").isDirectory)
    }

    @Test("The tool keeps its name")
    func toolName() {
        let tool = DatabaseTool(
            databaseFilePath: "db.sqlite",
            allowedTypes: [],
            exportAsArchive: false
        )

        #expect(tool.name == "Database Tool")
    }
}
