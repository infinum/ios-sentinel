//
//  DeviceAndApplicationToolTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Device and Application tabs")
struct DeviceAndApplicationToolTests {

    // MARK: - DeviceTool

    @Test("Device tab has its sections, starting with the platform's Device rows")
    func deviceSection() {
        let tool = DeviceTool()
        let table = tool.toolTable

        #expect(tool.name == "Device")
        #expect(table.sections.map(\.title) == ["Device", "Power", "Screen", "Locale", "Accessibility"])
        #if os(iOS)
        let expected = [
            "Manufacturer",
            "Model identifier",
            "Name",
            "System version",
            "UUID",
            "Architecture",
            "Simulator",
            "Runs on"
        ]
        #else
        let expected = ["Manufacturer", "Model identifier", "Name", "System version", "UUID", "Architecture"]
        #endif
        #expect(table.sections.first?.items.map(\.id) == expected)
    }

    @Test("Device info description lists every field on its own line")
    func deviceInfoDescription() {
        let info = DeviceTool.Info()
        let lines = info.description.components(separatedBy: "\n")

        #expect(lines.count == 5)
        #expect(lines[0] == "Manufacturer: Apple")
        #expect(lines[1] == "Device model: \(info.model)")
        #expect(lines[2] == "Device OS: \(info.systemVersion)")
        #expect(lines[3] == "Device ID: \(info.UUID)")
        #expect(lines[4].isEmpty)
    }

    @Test("Device info survives a Codable round trip")
    func deviceInfoCodable() throws {
        let info = DeviceTool.Info()

        let decoded = try JSONDecoder().decode(DeviceTool.Info.self, from: JSONEncoder().encode(info))

        #expect(decoded.description == info.description)
    }

    // MARK: - ApplicationTool

    @Test("Application tab has the runtime, plist and full bundle sections")
    func applicationSections() {
        let tool = ApplicationTool()
        let table = tool.toolTable

        #expect(tool.name == "Application")
        #expect(table.sections.map(\.title) == ["Runtime", "Standard Plist Info", "Bundle all info"])
        #expect(
            table.sections.first { $0.title == "Standard Plist Info" }?.items.map(\.id) == [
                "App version",
                "Build version",
                "Bundle name",
                "Executable name",
                "Bundle id",
                "Localizations",
                "Development region",
                "Version of the plist"
            ]
        )
        #expect(table.sections.last?.items.count == Bundle.main.infoDictionary?.count ?? 0)
    }

    @Test("A missing plist key reads as an empty string")
    func missingPlistKey() {
        #expect(ApplicationInfoProvider.stringFromPlist(for: "SentinelTestsMissingKey") == "")
    }

    // `swift test` on macOS runs from a runner without an Info.plist, so this only runs in a bundled host.
    @Test("A present plist key reads its value", .enabled(if: Bundle.main.bundleIdentifier != nil))
    func presentPlistKey() throws {
        let identifier = try #require(Bundle.main.bundleIdentifier)

        #expect(ApplicationInfoProvider.stringFromPlist(for: kCFBundleIdentifierKey) == identifier)
    }
}
