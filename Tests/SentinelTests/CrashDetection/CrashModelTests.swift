//
//  CrashModelTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Crash model")
struct CrashModelTests {

    @Test("A crash survives a JSON round trip")
    func codableRoundTrip() throws {
        let crash = CrashModel(
            type: .signal,
            details: CrashModel.Details.builder(name: "SIGABRT"),
            traces: [CrashModel.StackTrace(title: "frame", detail: "detail")]
        )

        let decoded = try JSONDecoder().decode(CrashModel.self, from: JSONEncoder().encode(crash))

        #expect(decoded == crash)
        #expect(decoded.type == .signal)
        #expect(decoded.traces.map(\.title) == ["frame"])
        #expect(decoded.traces.map(\.detail) == ["detail"])
        #expect(abs(decoded.details.date.timeIntervalSince(crash.details.date)) < 1)
        #expect(decoded.details.deviceInfo.description == crash.details.deviceInfo.description)
    }

    @Test("Crashes are equal when their names match")
    func equalityUsesName() {
        let first = CrashModel(
            type: .signal,
            details: CrashModel.Details.builder(name: "Same"),
            traces: []
        )
        let second = CrashModel(
            type: .nsexception,
            details: CrashModel.Details.builder(name: "Same"),
            traces: []
        )
        let third = CrashModel(
            type: .signal,
            details: CrashModel.Details.builder(name: "Other"),
            traces: []
        )

        #expect(first == second)
        #expect(first != third)
    }

    @Test("The default traces are the current call stack")
    func defaultTraces() {
        let crash = CrashModel(type: .signal, details: CrashModel.Details.builder(name: "Stack"))

        #expect(!crash.traces.isEmpty)
    }

    @Test("Each crash type has its own file name", arguments: [(CrashType.nsexception, "nsexception_crashes.json"), (.signal, "signal_crashes.json")])
    func fileNames(type: CrashType, expected: String) {
        #expect(type.fileName == expected)
    }
}
