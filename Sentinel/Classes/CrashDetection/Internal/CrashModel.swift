//
//  CrashModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

// Inspiration link: https://github.com/DebugSwift/DebugSwift

import Foundation

struct CrashModel: Codable {
    public let type: CrashType
    public let details: Details
    public let traces: [StackTrace]

    init(
        type: CrashType,
        details: Details,
        traces: [StackTrace] = .builder()
    ) {
        self.type = type
        self.details = details
        self.traces = traces
    }

}

// MARK: - Equatable conformance

extension CrashModel: Equatable {

    static func == (lhs: CrashModel, rhs: CrashModel) -> Bool {
        lhs.details.name == rhs.details.name
    }

}

// MARK: - Nested models

// MARK: - Details

extension CrashModel {

    struct Details: Codable {

        let name: String
        let date: Date
        let deviceInfo: DeviceTool.Info

        /// Local date and time of the crash, down to the second
        var formattedDate: String {
            date.formatted(date: .abbreviated, time: .standard)
        }

        /// `formattedDate` followed by the time zone, so a shared crash stays unambiguous
        var formattedDateWithTimeZone: String {
            date.formatted(Date.FormatStyle(date: .abbreviated, time: .standard).timeZone())
        }

        static func builder(name: String) -> Self {
            .init(
                name: name,
                date: .init(),
                deviceInfo: .init()
            )
        }
    }

}

// MARK: - Trace

extension CrashModel {

    struct StackTrace: Codable {
        public let title: String
        public let detail: String
    }

}

// MARK: - Trace image and symbol

extension CrashModel.StackTrace {

    /// The image (app, framework or library) in `title`, without the frame index before it;
    /// `nil` when `title` has no address
    var image: String? {
        guard let addressStart = title.range(of: " 0x") else { return nil }

        let image = title[..<addressStart.lowerBound]
            .drop { $0.isNumber }
            .trimmingCharacters(in: .whitespaces)
        return image.isEmpty ? nil : image
    }

    /// The symbol in `title`, without the frame index, image, address and `+ offset` that `Thread.callStackSymbols` adds;
    /// the whole `title` when it has no address
    var symbol: String {
        guard
            let addressStart = title.range(of: " 0x"),
            let addressEnd = title[addressStart.upperBound...].firstIndex(of: " ")
        else { return title }

        let symbol = String(title[addressEnd...].drop { $0 == " " })
        if let offset = symbol.range(of: " + ", options: .backwards),
           symbol[offset.upperBound...].allSatisfy(\.isNumber) {
            return String(symbol[..<offset.lowerBound])
        }
        return symbol
    }
}

// MARK: - Search

extension CrashModel {

    /// A crash with the text search looks at, prepared once when the list loads rather than on every keystroke
    struct Searchable: Identifiable {
        /// Position in the loaded list, so crashes sharing a date still get a row each
        let id: Int
        let crash: CrashModel
        /// Lowercased name and formatted date, the text the row shows
        private let rowFields: [String]
        private let frames: [Frame]

        init(id: Int, crash: CrashModel) {
            self.id = id
            self.crash = crash
            rowFields = [crash.details.name, crash.details.formattedDate].map { $0.lowercased() }
            frames = crash.traces.map(Frame.init)
        }

        /// Returns `nil` when a term is missing from the name, the formatted date and every frame's image and symbol
        /// - Parameter terms: Lowercased search terms
        func result(for terms: [String]) -> SearchResult? {
            let frameTerms = terms.filter { term in
                !rowFields.contains { $0.contains(term) }
            }
            guard !frameTerms.isEmpty else { return SearchResult(id: id, crash: crash, matchedFrame: nil) }

            let allFound = frameTerms.allSatisfy { term in
                frames.contains { $0.matches(term) }
            }
            guard allFound else { return nil }

            let matchedFrame = frames.first { frame in
                frameTerms.contains(where: frame.matches)
            }
            return SearchResult(id: id, crash: crash, matchedFrame: matchedFrame?.text(matching: frameTerms))
        }

        /// A stack trace frame's image and symbol, with lowercased copies to match against
        private struct Frame {
            let image: String?
            let symbol: String
            private let lowercasedImage: String?
            private let lowercasedSymbol: String

            init(_ trace: CrashModel.StackTrace) {
                image = trace.image
                symbol = trace.symbol
                lowercasedImage = image?.lowercased()
                lowercasedSymbol = symbol.lowercased()
            }

            func matches(_ term: String) -> Bool {
                imageContains(term) || symbolContains(term)
            }

            /// The frame as "Matched in" shows it: the symbol, preceded by the image when a term is in the image
            func text(matching terms: [String]) -> String {
                guard let image, terms.contains(where: imageContains) else { return symbol }
                return "\(image) \(symbol)"
            }

            private func imageContains(_ term: String) -> Bool {
                lowercasedImage?.contains(term) == true
            }

            private func symbolContains(_ term: String) -> Bool {
                // Numbers in symbols are only mangled name lengths, so a number has to be in the name, date or image
                !term.allSatisfy(\.isNumber) && lowercasedSymbol.contains(term)
            }
        }
    }

    /// A crash that matched a search
    struct SearchResult: Identifiable {
        /// The `id` of the `Searchable` it came from
        let id: Int
        let crash: CrashModel
        /// First frame containing a term the row's name and date don't show, `nil` when they show every term
        let matchedFrame: String?
    }
}

// MARK: - Trace helper

extension [CrashModel.StackTrace] {

    static func builder() -> Self {
        var traces = [CrashModel.StackTrace]()
        for symbol in Thread.callStackSymbols {
            let trace = CrashModel.StackTrace(
                title: symbol,
                detail: detailsInfo(from: symbol)
            )
            traces.append(trace)
        }

        return traces
    }

    @StringBuilder
    private static func detailsInfo(from symbol: String) -> String {
        if let className = StackTrace.classNameFromSymbol(symbol) {
            "Class: \(className)"
            String.newLine
        }
        if let fileInfo = StackTrace.fileInfoFromSymbol(symbol) {
            "File: \(fileInfo.file)"
            String.newLine
            "Line: \(fileInfo.line)"
            String.newLine
            "Function: \(fileInfo.function)"
            String.newLine
        }
    }
}

