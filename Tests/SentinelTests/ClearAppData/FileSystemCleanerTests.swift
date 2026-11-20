//
//  FileSystemCleanerTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

#if os(iOS)
import Foundation
import Testing
@testable import Sentinel

@Suite("File system cleaner")
struct FileSystemCleanerTests {

    @Test("Clearing removes every item but keeps the directory")
    func clearsContents() throws {
        let directory = try TemporaryDirectory()
        try directory.createFile(named: "a.txt")
        try directory.createFile(named: "b.txt")
        try FileManager.default.createDirectory(
            at: directory.url.appendingPathComponent("nested"),
            withIntermediateDirectories: true
        )

        let failures = FileSystemCleaner.clearContents(of: directory.url, step: .temporaryDirectory)

        #expect(failures.isEmpty)
        #expect(FileManager.default.fileExists(atPath: directory.url.path))
        #expect(try FileManager.default.contentsOfDirectory(atPath: directory.url.path).isEmpty)
    }

    @Test("A missing directory is not a failure")
    func missingDirectory() throws {
        let directory = try TemporaryDirectory()
        let missing = directory.url.appendingPathComponent("missing", isDirectory: true)

        #expect(FileSystemCleaner.clearContents(of: missing, step: .cachesDirectory).isEmpty)
    }

    @Test("A file in place of a directory is reported as a failure")
    func fileInsteadOfDirectory() throws {
        let directory = try TemporaryDirectory()
        let file = try directory.createFile(named: "file.txt")

        let failures = FileSystemCleaner.clearContents(of: file, step: .documentsDirectory)

        #expect(failures.count == 1)
        #expect(failures.first?.step == .documentsDirectory)
        #expect(failures.first?.kind == .failed)
    }

    @Test("Search path directories resolve")
    func directoryURLs() {
        #expect(FileSystemCleaner.url(for: .cachesDirectory) != nil)
        #expect(FileSystemCleaner.temporaryDirectoryURL.hasDirectoryPath)
    }
}
#endif
