//
//  CrashModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

import Foundation

public struct CrashModel: Codable {
    public let type: CrashType
    public let details: Details
    public let traces: [Trace]

    init(
        type: CrashType,
        details: Details,
        traces: [Trace] = .builder()
    ) {
        self.type = type
        self.details = details
        self.traces = traces
    }

}

// MARK: - Extensions -

// MARK: - Equatable conformance

extension CrashModel: Equatable {

    public static func == (lhs: CrashModel, rhs: CrashModel) -> Bool {
        lhs.details.name == rhs.details.name
    }

}

// MARK: - Nested models

// MARK: - Details

public extension CrashModel {

    struct Details: Codable {

        public let name: String
        public let date: Date

        static func builder(name: String) -> Self {
            .init(
                name: name,
                date: .init()
            )
        }
    }

}

// MARK: - Trace

public extension CrashModel {

    struct Trace: Codable {
        public let title: String
        public let detail: String
    }

}

// MARK: - Trace helper

extension [CrashModel.Trace] {

    static func builder() -> Self {
        var traces = [CrashModel.Trace]()
        for symbol in Thread.callStackSymbols {
            let trace = CrashModel.Trace(
                title: symbol,
                detail: detailsInfo(from: symbol)
            )
            traces.append(trace)
        }

        return traces
    }

    @StringBuilder
    private static func detailsInfo(from symbol: String) -> String {
        if let className = Trace.classNameFromSymbol(symbol) {
            "Class: \(className)"
            String.newLine
        }
        if let fileInfo = Trace.fileInfoFromSymbol(symbol) {
            "File: \(fileInfo.file)"
            String.newLine
            "Line: \(fileInfo.line)"
            String.newLine
            "Function: \(fileInfo.function)"
            String.newLine
        }
    }
}

