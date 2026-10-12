//
//  ClearAppDataReportTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

#if os(iOS)
import Testing
@testable import Sentinel

@Suite("Clear app data report")
struct ClearAppDataReportTests {

    private let footer = "Force-quit the app and launch it again. Data already loaded in memory is still active until you do."

    @Test("An empty report is a success with only the footer")
    func emptyReport() {
        let report = ClearAppDataReport(failures: [])

        #expect(report.isFullySuccessful)
        #expect(report.title == "Data cleared")
        #expect(report.message == footer)
    }

    @Test("Warnings alone still count as success")
    func warningsAreSuccess() {
        let report = ClearAppDataReport(
            failures: [
                ClearAppDataFailure(
                    step: .cachesDirectory,
                    item: "Snapshots",
                    reason: "skipped (system-managed)",
                    kind: .warning
                )
            ]
        )

        #expect(report.isFullySuccessful)
        #expect(report.title == "Data cleared")
        #expect(report.message == "• Caches directory — Snapshots: skipped (system-managed)\n\n\(footer)")
    }

    @Test("A failure marks the report as cleared with errors")
    func failureIsReported() {
        let report = ClearAppDataReport(failures: [ClearAppDataFailure(step: .keychain, reason: "denied")])

        #expect(!report.isFullySuccessful)
        #expect(report.title == "Cleared with errors")
        #expect(report.message == "• Keychain: denied\n\n\(footer)")
    }

    @Test("Failures are listed before warnings")
    func failuresBeforeWarnings() {
        let report = ClearAppDataReport(
            failures: [
                ClearAppDataFailure(
                    step: .temporaryDirectory,
                    reason: "warning",
                    kind: .warning
                ),
                ClearAppDataFailure(step: .keychain, reason: "failure")
            ]
        )

        let lines = report.message.components(separatedBy: "\n")

        #expect(Array(lines.prefix(2)) == ["• Keychain: failure", "• Temporary directory: warning"])
    }

    @Test("At most five lines are listed and the rest are counted")
    func listIsCapped() {
        let failures = (1...8).map { index in
            ClearAppDataFailure(
                step: .documentsDirectory,
                item: "file\(index)",
                reason: "busy"
            )
        }
        let report = ClearAppDataReport(failures: failures)

        let lines = report.message.components(separatedBy: "\n")

        #expect(lines.filter { $0.hasPrefix("•") }.count == 5)
        #expect(lines.contains("…and 3 more"))
        #expect(lines.last == footer)
    }

    @Test("Every step has a title")
    func stepTitles() {
        #expect(ClearAppDataStep.allCases.count == 9)
        #expect(ClearAppDataStep.allCases.allSatisfy { !$0.title.isEmpty })
        #expect(Set(ClearAppDataStep.allCases.map(\.title)).count == ClearAppDataStep.allCases.count)
    }

    @Test("Failures default to the failed kind and no item")
    func failureDefaults() {
        let failure = ClearAppDataFailure(step: .cookies, reason: "reason")

        #expect(failure.kind == .failed)
        #expect(failure.item == nil)
    }
}
#endif
