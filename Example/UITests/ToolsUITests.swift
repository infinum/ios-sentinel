//
//  ToolsUITests.swift
//  Example-iOSUITests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import XCTest

@MainActor
final class ToolsUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testEveryToolOpensAndNavigatesBack() {
        let screen = SentinelScreen.launch()
        screen.open()

        for tool in ToolNames.all {
            screen.openTool(tool)
            XCTAssertTrue(screen.waitUntilGone(screen.row(tool)), "\(tool) didn't open")

            screen.goBack()
            XCTAssertTrue(screen.row(tool).waitForExistence(timeout: 5), "Couldn't go back from \(tool)")
        }
    }

    func testCrashDetectionShowsAnEmptyList() {
        let screen = SentinelScreen.launch()
        screen.open()

        screen.openTool(ToolNames.crashDetection)

        XCTAssertTrue(screen.app.staticTexts["No crashes available"].waitForExistence(timeout: 5))
        screen.element("sentinel.crashes.deleteAll").tap()
        XCTAssertTrue(screen.app.staticTexts["No crashes available"].exists)
    }

    func testBaseURLIsSavedAndSurvivesARelaunch() {
        XCTExpectFailure(
            "On iOS 26 the text field sits under the large navigation title, so tapping it never gives it focus",
            options: XCTExpectedFailure.Options.nonStrict()
        )
        let newURL = "https://staging.example.com"
        let screen = SentinelScreen.launch()
        screen.open()

        screen.openTool(ToolNames.baseURL)
        let field = screen.element("sentinel.textEditing.field")
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.replaceText(with: newURL)
        screen.element("sentinel.textEditing.save").tap()

        XCTAssertTrue(screen.row(ToolNames.baseURL).waitForExistence(timeout: 5), "Saving didn't go back")
        screen.row(ToolNames.baseURL).tap()
        XCTAssertEqual(screen.element("sentinel.textEditing.field").value as? String, newURL)

        let relaunched = SentinelScreen.launch(resetState: false)
        relaunched.open()
        relaunched.openTool(ToolNames.baseURL)
        XCTAssertTrue(relaunched.element("sentinel.textEditing.field").waitForExistence(timeout: 5))
        XCTAssertEqual(relaunched.element("sentinel.textEditing.field").value as? String, newURL)
    }

    func testUserDefaultsValueCanBeEditedAndDeleted() {
        let key = "com.infinum.demo.clearDataTool.lastSavedDate"
        let screen = SentinelScreen.launch()
        saveStoredState(in: screen)
        screen.open()

        screen.openTool(ToolNames.userDefaults)
        screen.search(for: "lastSavedDate")
        XCTAssertTrue(screen.row(key).waitForExistence(timeout: 5))
        screen.row(key).tap()

        let editor = screen.element("sentinel.userDefaults.editor")
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.replaceText(with: "edited")
        screen.element("sentinel.userDefaults.save").tap()

        // Returning from the editor rebuilds the list and drops the search, so search again.
        screen.search(for: "lastSavedDate")
        XCTAssertTrue(screen.text(containing: "edited").waitForExistence(timeout: 5), "The list doesn't show the new value")

        screen.row(key).tap()
        XCTAssertTrue(screen.element("sentinel.userDefaults.delete").waitForExistence(timeout: 5))
        screen.element("sentinel.userDefaults.delete").tap()

        screen.search(for: "lastSavedDate")
        XCTAssertTrue(screen.waitUntilGone(screen.row(key)), "The deleted key is still listed")
    }

    func testClearAppDataWipesTheStoredState() {
        let screen = SentinelScreen.launch()
        saveStoredState(in: screen)
        screen.open()

        screen.openTool(ToolNames.clearAppData)
        screen.element("sentinel.clearAppData.clearAll").tap()

        let confirmation = screen.app.alerts["Clear all app data?"]
        XCTAssertTrue(confirmation.waitForExistence(timeout: 5))
        confirmation.buttons["Clear"].tap()

        let result = screen.app.alerts["Data cleared"]
        XCTAssertTrue(result.waitForExistence(timeout: 15), "No success alert")
        result.buttons["OK"].tap()

        screen.dismiss()
        screen.app.buttons["Menu"].tap()
        XCTAssertEqual(screen.app.staticTexts.matching(identifier: "No data stored").count, 2)
    }
}

private extension ToolsUITests {

    /// Uses the example app's menu to write a value to user defaults and the keychain.
    func saveStoredState(in screen: SentinelScreen) {
        screen.app.buttons["Menu"].tap()
        screen.app.buttons["Save current state"].tap()
        XCTAssertFalse(screen.app.staticTexts["No data stored"].exists)
        screen.app.navigationBars.buttons.element(boundBy: 0).tap()
    }
}
