//
//  SentinelReportTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.11.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Device and application report")
struct SentinelReportTests {

    // MARK: - Plain text sections

    @Test("A titled section gets an underlined heading followed by its rows")
    func titledSection() {
        let sections = [
            CustomInfoTool.Section(title: "Device", items: [
                CustomInfoTool.Item(title: "Model", value: "iPhone"),
                CustomInfoTool.Item(title: "OS", value: "26.1")
            ])
        ]

        #expect(sections.plainText == "Device\n------\nModel: iPhone\nOS: 26.1")
    }

    @Test("A section without a title has no heading")
    func untitledSection() {
        let sections = [
            CustomInfoTool.Section(items: [CustomInfoTool.Item(title: "Key", value: "Value")])
        ]

        #expect(sections.plainText == "Key: Value")
    }

    @Test("Sections are separated by a blank line, and empty ones are left out")
    func multipleSections() {
        let sections = [
            CustomInfoTool.Section(title: "A", items: [CustomInfoTool.Item(title: "One", value: "1")]),
            CustomInfoTool.Section(title: "Empty", items: []),
            CustomInfoTool.Section(title: "B", items: [CustomInfoTool.Item(title: "Two", value: "2")])
        ]

        #expect(sections.plainText == "A\n-\nOne: 1\n\nB\n-\nTwo: 2")
    }

    @Test("No sections give an empty text")
    func noSections() {
        #expect([CustomInfoTool.Section]().plainText.isEmpty)
    }

    // MARK: - Report

    @Test("The report has the device info and then the application info, each under its own heading")
    func reportLayout() throws {
        let report = SentinelReport.plainText
        let device = try #require(report.range(of: "DEVICE\n======\n\n"))
        let application = try #require(report.range(of: "\n\nAPPLICATION\n===========\n\n"))

        #expect(device.lowerBound == report.startIndex)
        #expect(device.upperBound <= application.lowerBound)
        #expect(report.contains(DeviceInfoProvider.sections.plainText))
        #expect(report.hasSuffix(ApplicationInfoProvider.reportSections.plainText))
    }

    @Test("The report leaves out the raw Info.plist dump")
    func reportSkipsBundleDump() {
        #expect(ApplicationInfoProvider.reportSections.map(\.title) == ["Runtime", "Standard Plist Info"])
        #expect(ApplicationInfoProvider.sections.map(\.title) == ["Runtime", "Standard Plist Info", "Bundle all info"])
        #expect(!SentinelReport.plainText.contains("Bundle all info"))
    }

    // MARK: - Share button

    @Test("Only the Device and Application tabs have a share button")
    func shareButtonTabs() {
        let tabItems = Sentinel.createTabItems(with: [MockTool(name: "Tool")], preferences: [])
        let tabsWithShare = tabItems
            .filter { $0.shareText != nil }
            .map(\.tabViewTab)

        #expect(tabsWithShare == [.device, .application])
    }

    // MARK: - Device sections

    @Test("The Power, Locale and Accessibility sections list the platform's rows")
    func deviceSectionRows() {
        let sections = DeviceInfoProvider.sections
        let rows = { (title: String) in
            sections.first { $0.title == title }?.items.map(\.title)
        }

        #if os(iOS)
        #expect(rows("Power") == ["Battery state", "Low Power Mode", "Thermal state"])
        #expect(rows("Accessibility") == [
            "Text size",
            "Appearance",
            "VoiceOver",
            "Reduce Motion",
            "Increase Contrast",
            "Bold Text"
        ])
        #else
        #expect(rows("Power") == ["Low Power Mode", "Thermal state"])
        #expect(rows("Accessibility") == ["Appearance", "VoiceOver", "Reduce Motion", "Increase Contrast"])
        #endif
        #expect(rows("Locale") == [
            "Locale identifier",
            "Language",
            "Region",
            "Preferred languages",
            "Time zone",
            "Calendar",
            "Currency",
            "Measurement system",
            "24-hour time"
        ])
    }

    @Test("Sizes are formatted as width × height with a unit, without trailing zeros")
    func sizeFormat() {
        #expect(DeviceInfoProvider.format(CGSize(width: 393, height: 852), unit: "pt") == "393 × 852 pt")
        #expect(DeviceInfoProvider.format(CGSize(width: 1179.5, height: 2556), unit: "px") == "1179.5 × 2556 px")
    }

    @Test("Flags read as Yes or No")
    func yesNo() {
        #expect(DeviceInfoProvider.yesNo(true) == "Yes")
        #expect(DeviceInfoProvider.yesNo(false) == "No")
    }
}
