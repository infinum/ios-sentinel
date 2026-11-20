//
//  TemporaryDirectory.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation

/// A unique directory under the temporary directory, deleted when the instance is deallocated.
final class TemporaryDirectory {

    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("SentinelTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }

    @discardableResult
    func createFile(named name: String, contents: String = "content") throws -> URL {
        let fileURL = url.appendingPathComponent(name)
        try Data(contents.utf8).write(to: fileURL)
        return fileURL
    }
}
