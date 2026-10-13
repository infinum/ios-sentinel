//
//  RemoteMock.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// An API mock as it travels between the device and Sentinel for Mac.
///
/// It's separate from the format the device saves mocks in: that one has to read old files forever, while
/// this one changes with the protocol version, and it carries what only the device can work out.
struct RemoteMock: Codable, Equatable, Identifiable {

    enum Response: Codable, Equatable {
        case http(statusCode: Int, headers: [String: String], body: Body)
        case networkError(String)
    }

    struct Body: Codable, Equatable {
        /// The body text. For a body read from a file, the file's text, or empty when it isn't UTF-8 text.
        var text: String
        /// The file the device reads the body from, or `nil` for a body written into the mock.
        var fileName: String?
    }

    var id: String
    var name: String
    var description: String
    var group: String?
    var method: String?
    var matchKind: String
    var pattern: String
    var response: Response
    var delay: TimeInterval
    var isLocal: Bool
    /// Worked out on the device, which has the body file the warning may be about.
    var warning: String?
}

enum RemoteMockError: Error, Equatable {
    case unknownMethod(String)
    case unknownMatchKind(String)
    case unknownNetworkError(String)
}

// MARK: - Converting

extension RemoteMock {

    init(mock: APIMock, isLocal: Bool) {
        id = mock.id
        name = mock.name
        description = mock.description
        group = mock.group
        method = mock.method?.rawValue
        matchKind = mock.url.kind.rawValue
        pattern = mock.url.pattern
        delay = mock.delay
        self.isLocal = isLocal
        warning = mock.warning
        switch mock.response {
        case .http(let statusCode, let headers, .json(let text)):
            response = Response.http(statusCode: statusCode, headers: headers, body: Body(text: text))
        case .http(let statusCode, let headers, .file(let url)):
            response = Response.http(
                statusCode: statusCode,
                headers: headers,
                body: Body(
                    text: (try? String(contentsOf: url, encoding: .utf8)) ?? "",
                    fileName: url.lastPathComponent
                )
            )
        case .networkError(let error):
            response = Response.networkError(error.rawValue)
        }
    }

    static func list(appMocks: [APIMock], localMocks: [APIMock]) -> [RemoteMock] {
        localMocks.map { RemoteMock(mock: $0, isLocal: true) }
            + appMocks.map { RemoteMock(mock: $0, isLocal: false) }
    }

    /// The mock with its body written into it, as Sentinel for Mac shows it and as an edited mock comes back
    /// to the device. Fails for a method, match or error this version doesn't know, rather than guessing.
    func makeAPIMock() throws -> APIMock {
        guard let kind = APIMock.URLPattern.Kind(rawValue: matchKind) else {
            throw RemoteMockError.unknownMatchKind(matchKind)
        }
        let httpMethod = try method.map { method in
            guard let httpMethod = APIMock.HTTPMethod(rawValue: method) else {
                throw RemoteMockError.unknownMethod(method)
            }
            return httpMethod
        }
        let apiResponse: APIMock.Response
        switch response {
        case .http(let statusCode, let headers, let body):
            apiResponse = APIMock.Response.http(
                statusCode: statusCode,
                headers: headers,
                body: APIMock.Body.json(body.text)
            )
        case .networkError(let name):
            guard let error = APIMock.NetworkError(rawValue: name) else {
                throw RemoteMockError.unknownNetworkError(name)
            }
            apiResponse = APIMock.Response.networkError(error)
        }
        return APIMock(
            id: id,
            name: name,
            description: description,
            group: group,
            method: httpMethod,
            url: APIMock.URLPattern(kind: kind, pattern: pattern),
            response: apiResponse,
            delay: delay
        )
    }
}

// MARK: - Switches and commands

/// Which mocks are switched on, sent apart from the mocks themselves, as it changes far more often.
struct RemoteMockSwitches: Codable, Equatable {

    var isMockingEnabled: Bool
    var enabledIDs: [String]
}

/// A change Sentinel for Mac asks the device to make. The device makes it through its own store, which keeps
/// rules such as one mock per endpoint in one place, and sends back what changed.
enum RemoteMockCommand: Codable, Equatable {

    case setMockingEnabled(Bool)
    case setEnabled(id: String, isEnabled: Bool)
    case save(RemoteMock)
    case delete(id: String)
}
