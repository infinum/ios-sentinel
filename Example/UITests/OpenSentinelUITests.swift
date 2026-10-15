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

