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

// MARK: - Trace symbol

extension CrashModel.StackTrace {

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
    struct Searchable {
        let crash: CrashModel
        /// Lowercased name and formatted date, the text the row shows
        private let rowFields: [String]
        private let symbols: [(original: String, lowercased: String)]

        init(_ crash: CrashModel) {
            self.crash = crash
            rowFields = [crash.details.name, crash.details.formattedDate].map { $0.lowercased() }
            symbols = crash.traces.map { trace in
                let symbol = trace.symbol
                return (symbol, symbol.lowercased())
            }
        }

        /// Returns `nil` when a term is missing from the name, the formatted date and every symbol
        /// - Parameter terms: Lowercased search terms
        func result(for terms: [String]) -> SearchResult? {
            let symbolTerms = terms.filter { term in
                !rowFields.contains { $0.contains(term) }
            }
            guard !symbolTerms.isEmpty else { return SearchResult(crash: crash, matchedSymbol: nil) }

            let allFound = symbolTerms.allSatisfy { term in
                // Numbers in symbols are only mangled name lengths, so a number has to be in the name or date
                !term.allSatisfy(\.isNumber) && symbols.contains { $0.lowercased.contains(term) }
            }
            guard allFound else { return nil }

            let matchedSymbol = symbols.first { symbol in
                symbolTerms.contains { symbol.lowercased.contains($0) }
            }
            return SearchResult(crash: crash, matchedSymbol: matchedSymbol?.original)
        }
    }

    /// A crash that matched a search
    struct SearchResult {
        let crash: CrashModel
        /// First symbol containing a term the row's name and date don't show, `nil` when they show every term
        let matchedSymbol: String?
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

