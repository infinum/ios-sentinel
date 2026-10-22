//
//  CustomInfoToolSection+PlainText.swift
//  Sentinel
//
//  Created by Karlo Čeh on 22.10.2026..
//

import Foundation

extension [CustomInfoTool.Section] {

    /// Plain text version of the sections, with an underlined heading and `Title: value` lines for each of them.
    /// A section without a title gets no heading, and a section without items is left out.
    var plainText: String {
        compactMap { section in
            guard !section.items.isEmpty else { return nil }

            let lines = section.items.map { "\($0.title): \($0.value)" }
            guard let title = section.title else { return lines.joined(separator: .newLine) }
            return ([title, String(repeating: "-", count: title.count)] + lines).joined(separator: .newLine)
        }
        .joined(separator: .newLine + .newLine)
    }
}
