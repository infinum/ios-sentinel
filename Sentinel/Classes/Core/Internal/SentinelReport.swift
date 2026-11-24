//
//  SentinelReport.swift
//  Sentinel
//
//  Created by Karlo Čeh on 22.10.2026..
//

import Foundation

/// The device and application information, read once when Sentinel opens. The Device and Application tabs show it
/// and share it as one text, so the shared report matches what is on screen.
struct SentinelReport {

    // MARK: - Internal properties

    let deviceSections: [CustomInfoTool.Section]
    /// The Application tab's sections without the raw `Info.plist` dump, which is long and doesn't go into the report.
    let applicationSections: [CustomInfoTool.Section]

    // MARK: - Lifecycle

    init(
        deviceSections: [CustomInfoTool.Section] = DeviceInfoProvider.sections,
        applicationSections: [CustomInfoTool.Section] = ApplicationInfoProvider.reportSections
    ) {
        self.deviceSections = deviceSections
        self.applicationSections = applicationSections
    }

    // MARK: - Report

    var plainText: String {
        [
            Self.heading("DEVICE"),
            deviceSections.plainText,
            Self.heading("APPLICATION"),
            applicationSections.plainText
        ]
        .joined(separator: .newLine + .newLine)
    }

    private static func heading(_ title: String) -> String {
        title + .newLine + String(repeating: "=", count: title.count)
    }
}
