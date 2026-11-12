//
//  TabsUITests.swift
//  Example-iOSUITests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import XCTest

@MainActor
final class TabsUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testInfoTabsShowTheirSections() {
        let screen = SentinelScreen.launch()
        screen.open()

        screen.selectTab("Device")
        XCTAssertTrue(screen.app.staticTexts["Model"].waitForExistence(timeout: 5))
        XCTAssertTrue(screen.app.staticTexts["System version"].exists)

        screen.selectTab("Application")
        XCTAssertTrue(screen.app.staticTexts["Standard Plist Info"].waitForExistence(timeout: 5))
        XCTAssertTrue(screen.app.staticTexts["Bundle id"].exists)

        screen.selectTab("Performance")
        XCTAssertTrue(screen.app.staticTexts["CPU"].waitForExistence(timeout: 5))
        XCTAssertTrue(screen.app.staticTexts["Memory"].exists)
        XCTAssertTrue(screen.app.staticTexts["System"].exists)
    }

    func testSearchFiltersTheList() {
        let screen = SentinelScreen.launch()
        screen.open()
        screen.selectTab("Device")
        XCTAssertTrue(screen.app.staticTexts["Name"].waitForExistence(timeout: 5))

        screen.search(for: "model")

        XCTAssertTrue(screen.app.staticTexts["Model"].waitForExistence(timeout: 5))
        XCTAssertTrue(screen.waitUntilGone(screen.app.staticTexts["Name"]))
    }

    func testPreferenceToggleSurvivesARelaunch() {
        let identifier = "sentinel.toggle.Analytics"
        let screen = SentinelScreen.launch()
        screen.open()
        screen.selectTab("Preferences")

        let toggle = screen.app.switches[identifier]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        let initialValue = toggle.value as? String
        toggle.tapSwitch()
        XCTAssertTrue(toggle.waitForValueChange(from: initialValue), "The toggle didn't change")
        let changedValue = toggle.value as? String

        let relaunched = SentinelScreen.launch(resetState: false)
        relaunched.open()
        relaunched.selectTab("Preferences")
        let relaunchedToggle = relaunched.app.switches[identifier]
        XCTAssertTrue(relaunchedToggle.waitForExistence(timeout: 5))
        XCTAssertEqual(relaunchedToggle.value as? String, changedValue)
    }
}
