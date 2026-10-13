//
//  APIMockDraft.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// The editor's copy of a mock: plain fields the form binds to, validated before it becomes a mock.
struct APIMockDraft: Equatable {

    enum ResponseKind: CaseIterable {
        case http
        case networkError
    }

    enum JSONStatus: Equatable {
        case empty
        case valid
        case invalid
    }

    private(set) var id: String
    var name = ""
    var description = ""
    var method: APIMock.HTTPMethod?
    var matchKind = APIMock.URLPattern.Kind.wildcard
    var pattern = ""
    var responseKind = ResponseKind.http
    var statusCode = "200"
    var body = ""
    var networkError = APIMock.NetworkError.notConnectedToInternet
    var delay: TimeInterval = 0
    // Not editable in the tool, but kept so editing a mock doesn't drop them.
    var headers: [String: String] = [:]

    /// A blank local mock.
    init() {
        id = "local.\(UUID().uuidString)"
    }

    /// The draft of an existing mock.
    init(mock: APIMock) {
        id = mock.id
        name = mock.name
        description = mock.description
        method = mock.method
        matchKind = mock.url.kind
        pattern = mock.url.pattern
        delay = mock.delay
        switch mock.response {
        case .http(let statusCode, let headers, let body):
            self.statusCode = String(statusCode)
            self.headers = headers
            self.body = (try? body.loadText()) ?? ""
        case .networkError(let error):
            responseKind = .networkError
            networkError = error
        }
    }

    /// A new local mock with the same request and response as `mock`.
    init(copying mock: APIMock) {
        self.init(mock: mock)
        id = "local.\(UUID().uuidString)"
        name = "\(mock.name) copy"
    }
}

// MARK: - Validation

extension APIMockDraft {

    var urlPattern: APIMock.URLPattern {
        APIMock.URLPattern(kind: matchKind, pattern: pattern)
    }

    /// Shown under the URL field; an empty pattern isn't an error until the mock is saved.
    var patternError: String? {
        guard !pattern.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return urlPattern.validationError
    }

    var statusCodeValue: Int? {
        Int(statusCode.trimmingCharacters(in: .whitespaces)).flatMap { (100...599).contains($0) ? $0 : nil }
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        guard !trimmedName.isEmpty, urlPattern.validationError == nil else { return false }
        return responseKind == .networkError || statusCodeValue != nil
    }

    /// Invalid JSON is only a warning: a malformed body is a fair thing to test with.
    var jsonStatus: JSONStatus {
        guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .empty }
        return JSONFormatter.isValid(JSONFormatter.repairingQuotes(in: body)) ? .valid : .invalid
    }

    /// Re-indents the body when it's valid JSON.
    mutating func formatBody() {
        let repaired = JSONFormatter.repairingQuotes(in: body)
        if let formatted = JSONFormatter.prettyPrinted(repaired) {
            body = formatted
        }
    }

    /// The mock the draft describes. Only meaningful when `canSave` is `true`.
    func makeMock() -> APIMock {
        let response: APIMock.Response
        switch responseKind {
        case .http:
            response = APIMock.Response.http(
                statusCode: statusCodeValue ?? 200,
                headers: headers,
                body: APIMock.Body.json(JSONFormatter.repairingQuotes(in: body))
            )
        case .networkError:
            response = APIMock.Response.networkError(networkError)
        }
        return APIMock(
            id: id,
            name: trimmedName,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            method: method,
            url: urlPattern,
            response: response,
            delay: delay
        )
    }
}

// MARK: - Sharing

extension APIMockDraft {

    /// A name usable as a file name and in code, e.g. `products-empty` for "Products – empty".
    var fileName: String {
        let words = trimmedName
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        return words.isEmpty ? "mock" : words.joined(separator: "-")
    }

    /// Swift code that adds the mock to the app, reading its body from `<fileName>.json`.
    var swiftSnippet: String {
        var arguments = ["name: \(swiftLiteral(trimmedName))"]
        let description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if !description.isEmpty {
            arguments.append("description: \(swiftLiteral(description))")
        }
        if let method {
            arguments.append("method: .\(String(describing: method))")
        }
        arguments.append("url: .\(matchKind.rawValue)(\(swiftLiteral(pattern.trimmingCharacters(in: .whitespacesAndNewlines))))")
        switch responseKind {
        case .http:
            if let statusCode = statusCodeValue, statusCode != 200 {
                arguments.append("statusCode: \(statusCode)")
            }
            arguments.append("body: .file(named: \(swiftLiteral(fileName)))")
        case .networkError:
            arguments.append("error: .\(networkError.rawValue)")
        }
        if delay > 0 {
            arguments.append("delay: \(delay)")
        }
        let lines = arguments.map { "    \($0)" }.joined(separator: ",\n")
        return "APIMock(\n\(lines)\n)"
    }

    private func swiftLiteral(_ text: String) -> String {
        let escaped = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}
