//
//  APIMockShare.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// What sharing a local mock hands over: its body as a JSON file, and the Swift code that adds the mock
/// to the app reading that file, so a developer can bundle what a tester made.
struct APIMockShare {

    let draft: APIMockDraft

    /// The snippet, and the body file when the mock answers with a body.
    func makeItems() -> [Any] {
        var items: [Any] = [swiftSnippet]
        guard draft.responseKind == .http else { return items }
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension("json")
        let body = JSONFormatter.prettyPrinted(JSONFormatter.repairingQuotes(in: draft.body)) ?? draft.body
        if (try? Data(body.utf8).write(to: fileURL, options: .atomic)) != nil {
            items.append(fileURL)
        }
        return items
    }

    /// A name usable as a file name and in code, e.g. `products-empty` for "Products – empty".
    var fileName: String {
        let words = draft.trimmedName
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        return words.isEmpty ? "mock" : words.joined(separator: "-")
    }

    /// Swift code that adds the mock to the app, reading its body from `<fileName>.json`.
    var swiftSnippet: String {
        var arguments = ["name: \(swiftLiteral(draft.trimmedName))"]
        let description = draft.description.trimmingCharacters(in: .whitespacesAndNewlines)
        if !description.isEmpty {
            arguments.append("description: \(swiftLiteral(description))")
        }
        if let group = draft.trimmedGroup {
            arguments.append("group: \(swiftLiteral(group))")
        }
        if let method = draft.method {
            arguments.append("method: .\(String(describing: method))")
        }
        let pattern = draft.pattern.trimmingCharacters(in: .whitespacesAndNewlines)
        arguments.append("url: .\(draft.matchKind.rawValue)(\(swiftLiteral(pattern)))")
        switch draft.responseKind {
        case .http:
            if let statusCode = draft.statusCodeValue, statusCode != 200 {
                arguments.append("statusCode: \(statusCode)")
            }
            arguments.append("body: .file(named: \(swiftLiteral(fileName)))")
        case .networkError:
            arguments.append("error: .\(draft.networkError.rawValue)")
        }
        if draft.delay > 0 {
            arguments.append("delay: \(draft.delay)")
        }
        let lines = arguments.map { "    \($0)" }.joined(separator: ",\n")
        return "APIMock(\n\(lines)\n)"
    }
}

// MARK: - Helpers

private extension APIMockShare {

    func swiftLiteral(_ text: String) -> String {
        let escaped = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}
