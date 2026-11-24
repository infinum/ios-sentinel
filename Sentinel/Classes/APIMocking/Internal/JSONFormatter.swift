//
//  JSONFormatter.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Checks and re-indents JSON typed or pasted into the mock editor.
enum JSONFormatter {

    static func isValid(_ text: String) -> Bool {
        (try? JSONSerialization.jsonObject(with: Data(text.utf8), options: [.fragmentsAllowed])) != nil
    }

    /// The JSON re-indented with two spaces, or `nil` when it isn't valid.
    ///
    /// Works on the text rather than through `JSONSerialization`, which would reorder keys and rewrite
    /// numbers such as `1234.10`.
    static func prettyPrinted(_ text: String) -> String? {
        guard isValid(text) else { return nil }

        let characters = Array(text)
        var result = ""
        var depth = 0
        var isInString = false
        var isEscaped = false

        func newLine() {
            result += "\n" + String(repeating: "  ", count: depth)
        }

        /// The next character that isn't whitespace, outside of strings.
        func nextSignificant(after index: Int) -> Character? {
            characters[(index + 1)...].first { !$0.isWhitespace }
        }

        for (index, character) in characters.enumerated() {
            if isInString {
                result.append(character)
                if isEscaped {
                    isEscaped = false
                } else if character == "\\" {
                    isEscaped = true
                } else if character == "\"" {
                    isInString = false
                }
                continue
            }

            switch character {
            case "\"":
                isInString = true
                result.append(character)
            case "{", "[":
                result.append(character)
                // Empty containers stay on one line.
                if let next = nextSignificant(after: index), next == "}" || next == "]" { continue }
                depth += 1
                newLine()
            case "}", "]":
                if let last = result.last, last != "{" && last != "[" {
                    depth -= 1
                    newLine()
                }
                result.append(character)
            case ",":
                result.append(character)
                newLine()
            case ":":
                result.append(": ")
            case let character where character.isWhitespace:
                continue
            default:
                result.append(character)
            }
        }
        return result
    }

    /// Straightens typographic quotes when that's what keeps the text from being valid JSON.
    ///
    /// Keyboards with smart punctuation turn typed `"` into `“` or `”`. Valid JSON is returned as it is,
    /// so typographic quotes inside string values, common in Croatian „text“, are left alone.
    static func repairingQuotes(in text: String) -> String {
        guard !isValid(text) else { return text }
        let repaired = text
            .replacingOccurrences(of: "[“”„‟″]", with: "\"", options: .regularExpression)
            .replacingOccurrences(of: "[‘’‚‛′]", with: "'", options: .regularExpression)
        return isValid(repaired) ? repaired : text
    }
}
