//
//  OpenSentinelUITests.swift
//  Example-iOSUITests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import XCTest

@MainActor
final class OpenSentinelUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testShakeOpensSentinelOnTheToolsTab() {
        let screen = SentinelScreen.launch()

        screen.open()

        for title in SentinelScreen.tabTitles {
            XCTAssertTrue(screen.tab(title).exists, "Missing the \(title) tab")
        }
        XCTAssertTrue(screen.tab("Tools").isSelected)
        XCTAssertTrue(screen.app.navigationBars["Tools"].exists)
    }

    func testSentinelCanBeClosedAndOpenedAgain() {
        let screen = SentinelScreen.launch()

        screen.open()
        screen.dismiss()
        screen.open()

        XCTAssertTrue(screen.tab("Tools").isSelected)
    }

    func testToolsTabListsEveryRegisteredTool() {
        let screen = SentinelScreen.launch()

        screen.open()

        for tool in ToolNames.all {
            XCTAssertTrue(screen.row(tool).waitForExistence(timeout: 2), "Missing the \(tool) row")
        }
    }
}

/// The tools registered by the example app's `AppDelegate`.
enum ToolNames {
    static let userDefaults = "User Defaults Inspector"
    static let baseURL = "Base URL"
    static let colorChange = "Color Change Tool"
    static let crashDetection = "Crash Detection Tool"
    static let clearAppData = "Clear App Data"
    static let customLocation = "Custom Location"
    static let pulse = "Pulse"

    static let all = [userDefaults, baseURL, colorChange, crashDetection, clearAppData, customLocation, pulse]
}
