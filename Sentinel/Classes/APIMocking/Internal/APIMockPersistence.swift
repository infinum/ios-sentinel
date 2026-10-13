//
//  APIMockPersistence.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Saves the local mocks and which mocks are switched on to a single JSON file.
///
/// The state lives in a file rather than in user defaults, because `ClearAppDataTool` wipes every
/// user defaults domain, and testers expect their mocks to survive a reset of the app.
struct APIMockPersistence {

    struct State: Equatable {
        var isMockingEnabled = true
        var enabledIDs: Set<String> = []
        var localMocks: [APIMock] = []
    }

    let fileURL: URL

    /// `Library/Sentinel/APIMocking.json` on iOS, which `ClearAppDataTool` leaves alone, as it clears
    /// Application Support but not the rest of Library. On macOS, where apps outside the sandbox share
    /// `~/Library`, it's under the app's own Application Support folder.
    static var defaultFileURL: URL {
        let fileManager = FileManager.default
        #if os(macOS)
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "Sentinel", isDirectory: true)
        #else
        let base = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        #endif
        return base
            .appendingPathComponent("Sentinel", isDirectory: true)
            .appendingPathComponent("APIMocking.json")
    }

    func load() -> State {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return State() }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(PersistedState.self, from: data).state
        } catch {
            // Kept for inspection; saving over it would throw away every mock a tester made.
            NSLog("Sentinel API mocking couldn't read %@ and moved it aside: %@", fileURL.path, "\(error)")
            moveAside()
            return State()
        }
    }

    func save(_ state: State) {
        let directory = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            excludeFromBackup(directory)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(PersistedState(state: state)).write(to: fileURL, options: .atomic)
        } catch {
            NSLog("Sentinel API mocking couldn't save %@: %@", fileURL.path, "\(error)")
        }
    }

    var corruptFileURL: URL {
        fileURL.deletingPathExtension().appendingPathExtension("corrupt.json")
    }
}

// MARK: - Helpers

private extension APIMockPersistence {

    func moveAside() {
        try? FileManager.default.removeItem(at: corruptFileURL)
        try? FileManager.default.moveItem(at: fileURL, to: corruptFileURL)
    }

    /// Mocks switched on in a backup shouldn't come back on a restored device.
    func excludeFromBackup(_ directory: URL) {
        var directory = directory
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? directory.setResourceValues(values)
    }
}

// MARK: - Stored format

// Every field is optional, so a file written by another version of the tool still loads.

private struct PersistedState: Codable {

    var version: Int?
    var isMockingEnabled: Bool?
    var enabledIDs: [String]?
    var localMocks: [PersistedMock]?

    init(state: APIMockPersistence.State) {
        version = 1
        isMockingEnabled = state.isMockingEnabled
        enabledIDs = state.enabledIDs.sorted()
        localMocks = state.localMocks.map(PersistedMock.init(mock:))
    }

    var state: APIMockPersistence.State {
        APIMockPersistence.State(
            isMockingEnabled: isMockingEnabled ?? true,
            enabledIDs: Set(enabledIDs ?? []),
            localMocks: (localMocks ?? []).compactMap(\.mock)
        )
    }
}

private struct PersistedMock: Codable {

    var id: String?
    var name: String?
    var description: String?
    var method: String?
    var matchKind: String?
    var pattern: String?
    var statusCode: Int?
    var headers: [String: String]?
    var body: String?
    var networkError: String?
    var delay: TimeInterval?

    init(mock: APIMock) {
        id = mock.id
        name = mock.name
        description = mock.description
        method = mock.method?.rawValue
        matchKind = mock.url.kind.rawValue
        pattern = mock.url.pattern
        delay = mock.delay
        switch mock.response {
        case .http(let statusCode, let headers, let body):
            self.statusCode = statusCode
            self.headers = headers.isEmpty ? nil : headers
            // Local mocks hold their body inline; a file body is copied in so the mock stands on its own.
            self.body = (try? body.loadText()) ?? ""
        case .networkError(let error):
            networkError = error.rawValue
        }
    }

    var mock: APIMock? {
        guard let id, let name, let pattern else { return nil }
        let response: APIMock.Response
        if let networkError = networkError.flatMap(APIMock.NetworkError.init(rawValue:)) {
            response = APIMock.Response.networkError(networkError)
        } else {
            response = APIMock.Response.http(
                statusCode: statusCode ?? 200,
                headers: headers ?? [:],
                body: APIMock.Body.json(body ?? "")
            )
        }
        return APIMock(
            id: id,
            name: name,
            description: description ?? "",
            method: method.flatMap(APIMock.HTTPMethod.init(rawValue:)),
            url: APIMock.URLPattern(
                kind: matchKind.flatMap(APIMock.URLPattern.Kind.init(rawValue:)) ?? .wildcard,
                pattern: pattern
            ),
            response: response,
            delay: delay ?? 0
        )
    }
}
