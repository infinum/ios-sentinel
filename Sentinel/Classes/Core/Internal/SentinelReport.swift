//
//  SentinelReport.swift
//  Sentinel
//
//  Created by Karlo Čeh on 22.10.2026..
//

import Foundation

/// The device and application information in a single text, which is what the Device and Application tabs share.
enum SentinelReport {

    static var plainText: String {
        [
            heading("DEVICE"),
            DeviceInfoProvider.sections.plainText,
            heading("APPLICATION"),
            ApplicationInfoProvider.reportSections.plainText
        ]
        .joined(separator: .newLine + .newLine)
    }

    private static func heading(_ title: String) -> String {
        title + .newLine + String(repeating: "=", count: title.count)
    }
}
