//
//  APIMock.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// A canned response that ``APIMockingTool`` serves in place of the network.
///
/// While a mock is switched on in the tool, it answers every request whose method and URL match it.
/// The request still goes through `URLSession`, so the app's own networking code, including
/// response validation and logging, runs as it would for a real response.
public struct APIMock: Identifiable, Equatable, Sendable {

    // MARK: - Public properties

    /// Identifies the mock. The tool remembers whether a mock is switched on by its `id`.
    public let id: String
    /// Name shown in the tool.
    public var name: String
    /// Short explanation shown under the name.
    public var description: String
    /// Name of the collapsible group the mock is listed in, or `nil` to list it on its own.
    public var group: String?
    /// The HTTP method the mock answers, or `nil` for any method.
    public var method: HTTPMethod?
    /// The URLs the mock answers.
    public var url: URLPattern
    /// What the mock answers with.
    public var response: Response
    /// Seconds to wait before answering.
    public var delay: TimeInterval

    // MARK: - Lifecycle

    /// Creates a mock that answers with an HTTP response.
    ///
    /// - Parameters:
    ///     - id: Identifies the mock; defaults to `name`. Set it to keep the mock switched on across renames.
    ///     - name: Name shown in the tool. Mocks passed to the tool need unique names, or unique ids.
    ///     - description: Short explanation shown under the name.
    ///     - group: Name of the collapsible group the mock is listed in, or `nil` to list it on its own.
    ///     - method: The HTTP method the mock answers, or `nil` for any method.
    ///     - url: The URLs the mock answers.
    ///     - statusCode: HTTP status code of the response.
    ///     - headers: Response headers. `Content-Type` defaults to `application/json`.
    ///     - body: Response body.
    ///     - delay: Seconds to wait before answering.
    public init(
        id: String? = nil,
        name: String,
        description: String = "",
        group: String? = nil,
        method: HTTPMethod? = nil,
        url: URLPattern,
        statusCode: Int = 200,
        headers: [String: String] = [:],
        body: Body,
        delay: TimeInterval = 0
    ) {
        self.init(
            id: id ?? name,
            name: name,
            description: description,
            group: group,
            method: method,
            url: url,
            response: Response.http(statusCode: statusCode, headers: headers, body: body),
            delay: delay
        )
    }

    /// Creates a mock that fails the request with a network error, as if the server couldn't be reached.
    ///
    /// - Parameters:
    ///     - id: Identifies the mock; defaults to `name`. Set it to keep the mock switched on across renames.
    ///     - name: Name shown in the tool. Mocks passed to the tool need unique names, or unique ids.
    ///     - description: Short explanation shown under the name.
    ///     - group: Name of the collapsible group the mock is listed in, or `nil` to list it on its own.
    ///     - method: The HTTP method the mock answers, or `nil` for any method.
    ///     - url: The URLs the mock answers.
    ///     - error: The error the request fails with.
    ///     - delay: Seconds to wait before failing.
    public init(
        id: String? = nil,
        name: String,
        description: String = "",
        group: String? = nil,
        method: HTTPMethod? = nil,
        url: URLPattern,
        error: NetworkError,
        delay: TimeInterval = 0
    ) {
        self.init(
            id: id ?? name,
            name: name,
            description: description,
            group: group,
            method: method,
            url: url,
            response: Response.networkError(error),
            delay: delay
        )
    }

    init(
        id: String,
        name: String,
        description: String,
        group: String?,
        method: HTTPMethod?,
        url: URLPattern,
        response: Response,
        delay: TimeInterval
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.group = group
        self.method = method
        self.url = url
        self.response = response
        self.delay = delay
    }
}

// MARK: - HTTPMethod

public extension APIMock {

    enum HTTPMethod: String, CaseIterable, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
        case head = "HEAD"
        case options = "OPTIONS"
    }
}

// MARK: - URLPattern

public extension APIMock {

    /// Describes which URLs a mock answers. Both kinds ignore case.
    enum URLPattern: Equatable, Sendable {
        /// Matches URLs that end with the pattern, where `*` stands for any run of characters.
        ///
        /// The query is ignored unless the pattern contains `?`, and a trailing `/` doesn't matter, so
        /// `/api/v2/products` matches `https://example.com/api/v2/products?page=2` but not
        /// `/api/v2/products/42`. Use `/api/v2/products*` for every URL under the path, or
        /// `/accounts/*/details` for a path with an identifier in it.
        case wildcard(String)
        /// A regular expression that has to match somewhere in the full URL.
        case regex(String)
    }
}

// MARK: - Response

public extension APIMock {

    enum Response: Equatable, Sendable {
        /// Answers with an HTTP response.
        case http(statusCode: Int, headers: [String: String], body: Body)
        /// Fails the request with a network error.
        case networkError(NetworkError)
    }
}

// MARK: - Body

public extension APIMock {

    enum Body: Equatable, Sendable {
        /// The body text, usually JSON.
        case json(String)
        /// A file whose contents are the body. It's read every time the mock answers.
        case file(URL)

        /// A body read from a file in a bundle.
        ///
        /// - Parameters:
        ///     - name: Name of the file, without its extension.
        ///     - fileExtension: Extension of the file.
        ///     - bundle: The bundle holding the file.
        public static func file(
            named name: String,
            withExtension fileExtension: String = "json",
            in bundle: Bundle = .main
        ) -> Body {
            // A missing file still gets a URL, so the tool and the failed request can say which file it expected.
            let url = bundle.url(forResource: name, withExtension: fileExtension)
                ?? bundle.bundleURL.appendingPathComponent(name).appendingPathExtension(fileExtension)
            return Body.file(url)
        }
    }
}

// MARK: - NetworkError

public extension APIMock {

    /// Network errors a mock can fail a request with.
    enum NetworkError: String, CaseIterable, Sendable {
        case notConnectedToInternet
        case timedOut
        case cannotConnectToHost
        case cannotFindHost
        case networkConnectionLost
        case secureConnectionFailed

        /// The `URLError` code the request fails with.
        public var code: URLError.Code {
            switch self {
            case .notConnectedToInternet: return .notConnectedToInternet
            case .timedOut: return .timedOut
            case .cannotConnectToHost: return .cannotConnectToHost
            case .cannotFindHost: return .cannotFindHost
            case .networkConnectionLost: return .networkConnectionLost
            case .secureConnectionFailed: return .secureConnectionFailed
            }
        }
    }
}
