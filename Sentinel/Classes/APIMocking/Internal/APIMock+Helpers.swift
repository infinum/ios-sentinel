//
//  APIMock+Helpers.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

// MARK: - URLPattern

extension APIMock.URLPattern {

    enum Kind: String, CaseIterable {
        case wildcard
        case regex

        var title: String {
            switch self {
            case .wildcard: return "Wildcard"
            case .regex: return "Regex"
            }
        }
    }

    init(kind: Kind, pattern: String) {
        switch kind {
        case .wildcard: self = APIMock.URLPattern.wildcard(pattern)
        case .regex: self = APIMock.URLPattern.regex(pattern)
        }
    }

    var kind: Kind {
        switch self {
        case .wildcard: return .wildcard
        case .regex: return .regex
        }
    }

    var pattern: String {
        switch self {
        case .wildcard(let pattern), .regex(let pattern):
            return pattern.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    /// The expression the pattern is matched with, or `nil` when the pattern is empty or not a valid regex.
    func makeRegularExpression() -> NSRegularExpression? {
        try? compile()
    }

    /// Why the pattern can't match anything, or `nil` when it's usable.
    var validationError: String? {
        do {
            _ = try compile()
            return nil
        } catch PatternError.empty {
            return "The URL pattern is empty."
        } catch {
            return "Invalid regular expression."
        }
    }

    func matches(_ url: String) -> Bool {
        guard let expression = makeRegularExpression() else { return false }
        return expression.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) != nil
    }
}

private extension APIMock.URLPattern {

    enum PatternError: Error {
        case empty
    }

    func compile() throws -> NSRegularExpression {
        guard !pattern.isEmpty else { throw PatternError.empty }
        switch kind {
        case .wildcard:
            let body = NSRegularExpression.escapedPattern(for: pattern)
                .replacingOccurrences(of: "\\*", with: ".*")
            // Without a `?` the pattern describes a path, so the query and a trailing slash are let through.
            let ending = pattern.contains("?") ? "$" : "/?(\\?.*)?$"
            return try NSRegularExpression(pattern: body + ending, options: [.caseInsensitive])
        case .regex:
            return try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        }
    }
}

// MARK: - Endpoint

extension APIMock {

    /// `true` when both mocks answer the same requests, so only one of them should be switched on.
    ///
    /// That's the case when the patterns are written the same way and the methods overlap, a mock for any
    /// method overlapping every other method. Patterns that differ but happen to match the same URL don't
    /// count; for those, the first match wins.
    func sharesEndpoint(with other: APIMock) -> Bool {
        guard id != other.id, url.kind == other.url.kind else { return false }
        guard url.pattern.lowercased() == other.url.pattern.lowercased() else { return false }
        guard let method, let otherMethod = other.method else { return true }
        return method == otherMethod
    }
}

// MARK: - Presentation

extension APIMock {

    /// The requests the mock answers, e.g. `GET /api/v2/products` or `ANY regex /users/\d+$`.
    var requestSummary: String {
        let methodName = method?.rawValue ?? "ANY"
        switch url.kind {
        case .wildcard: return "\(methodName) \(url.pattern)"
        case .regex: return "\(methodName) regex \(url.pattern)"
        }
    }

    /// What the mock answers with, e.g. `200` or `No internet connection · 2s delay`.
    var responseSummary: String {
        var parts: [String]
        switch response {
        case .http(let statusCode, _, _): parts = ["\(statusCode)"]
        case .networkError(let error): parts = [error.title]
        }
        if delay > 0 {
            parts.append("\(delay.formattedSeconds) delay")
        }
        return parts.joined(separator: " · ")
    }

    /// Why the mock can't answer as intended, or `nil` when it can.
    var warning: String? {
        if let error = url.validationError {
            return error
        }
        if case .http(_, _, .file(let url)) = response, !FileManager.default.fileExists(atPath: url.path) {
            return "Missing body file \(url.lastPathComponent)."
        }
        return nil
    }
}

extension APIMock.NetworkError {

    var title: String {
        switch self {
        case .notConnectedToInternet: return "No internet connection"
        case .timedOut: return "Timed out"
        case .cannotConnectToHost: return "Cannot connect to host"
        case .cannotFindHost: return "Cannot find host"
        case .networkConnectionLost: return "Connection lost"
        case .secureConnectionFailed: return "Secure connection failed"
        }
    }

    /// The description the system gives the error, which apps often show as it is.
    var systemDescription: String {
        switch self {
        case .notConnectedToInternet: return "The Internet connection appears to be offline."
        case .timedOut: return "The request timed out."
        case .cannotConnectToHost: return "Could not connect to the server."
        case .cannotFindHost: return "A server with the specified hostname could not be found."
        case .networkConnectionLost: return "The network connection was lost."
        case .secureConnectionFailed: return "An SSL error has occurred and a secure connection to the server cannot be made."
        }
    }
}

extension TimeInterval {

    /// `2s`, `0.5s`.
    var formattedSeconds: String {
        let value = self == rounded() ? String(Int(self)) : String(format: "%.1f", self)
        return "\(value)s"
    }
}

// MARK: - Body

extension APIMock.Body {

    func loadData() throws -> Data {
        switch self {
        case .json(let text):
            return Data(text.utf8)
        case .file(let url):
            return try Data(contentsOf: url)
        }
    }

    func loadText() throws -> String {
        switch self {
        case .json(let text):
            return text
        case .file(let url):
            return try String(contentsOf: url, encoding: .utf8)
        }
    }
}
