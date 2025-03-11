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

