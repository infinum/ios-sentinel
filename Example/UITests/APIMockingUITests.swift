//
//  APIMockingUITests.swift
//  Example-iOSUITests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import XCTest

/// The example app's Fetch repository button requests this repository from GitHub; these tests answer it with mocks.
@MainActor
final class APIMockingUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testAppMockAnswersTheRequest() {
        let screen = SentinelScreen.launch()
        screen.open()
        screen.openTool(ToolNames.apiMocking)
        switchOnRepositoryMock(in: screen)

        XCTAssertTrue(fetchRepository(in: screen).contains("★ 1234"))
        XCTAssertFalse(screen.toast.exists, "A request toast showed while they're switched off")
    }

    func testRequestToastNamesTheMock() {
        let screen = SentinelScreen.launch()
        screen.open()
        screen.openTool(ToolNames.apiMocking)
        screen.element("sentinel.apiMocking.requestToastSwitch").tapSwitch()
        switchOnRepositoryMock(in: screen)

        _ = fetchRepository(in: screen)

        XCTAssertTrue(screen.toast.waitForExistence(timeout: 5), "No toast for the mocked request")
        XCTAssertTrue(screen.toast.label.contains("Mocked by “Repository”"), screen.toast.label)
    }

    func testLaunchToastShowsWhileAMockIsOn() {
        let screen = SentinelScreen.launch()
        XCTAssertTrue(screen.openButton.waitForExistence(timeout: 5), "The example app isn't showing")
        XCTAssertFalse(screen.toast.exists, "A toast showed with no mock on")
        screen.open()
        screen.openTool(ToolNames.apiMocking)
        switchOnRepositoryMock(in: screen)

        let relaunched = SentinelScreen.launch(resetState: false)

        XCTAssertTrue(relaunched.toast.waitForExistence(timeout: 5), "No toast at launch")
        XCTAssertTrue(relaunched.toast.label.contains("Repository"), relaunched.toast.label)
        XCTAssertTrue(relaunched.waitUntilGone(relaunched.toast, timeout: 6), "The toast didn't go away")
    }

    func testLocalMockCanBeCreatedAndAnswersTheRequest() {
        let screen = SentinelScreen.launch()
        screen.open()
        screen.openTool(ToolNames.apiMocking)

        screen.element("sentinel.apiMocking.new").tap()
        let nameField = screen.element("sentinel.apiMocking.name")
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "The editor didn't open")
        nameField.focus()
        nameField.typeText("Local repository")
        let patternField = screen.element("sentinel.apiMocking.pattern")
        patternField.focus()
        patternField.typeText("/repos/infinum/ios-sentinel")

        screen.element("sentinel.apiMocking.bodyRow").tap()
        let bodyEditor = screen.element("sentinel.apiMocking.body")
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 5), "The body screen didn't open")
        XCTAssertTrue(screen.waitUntilHittable(bodyEditor), "The body editor isn't ready")
        // The editor's top runs under the navigation bar, so tap a little below it.
        bodyEditor.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)).tap()
        XCTAssertTrue(
            XCTWaiter().wait(
                for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "hasKeyboardFocus == true"), object: bodyEditor)],
                timeout: 3
            ) == .completed,
            "The body editor didn't take focus"
        )
        // The keyboard may turn the quotes typographic; the tool straightens them when saving.
        screen.app.typeText(#"{"description":"Made in the tool","stargazers_count":7}"#)
        screen.app.navigationBars["Body"].buttons.element(boundBy: 0).tap()

        screen.element("sentinel.apiMocking.save").tap()
        let toggle = screen.element("sentinel.toggle.Local repository")
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), "The mock wasn't saved")
        toggle.tapSwitch()

        XCTAssertTrue(fetchRepository(in: screen).contains("★ 7 · Made in the tool"))
    }

    func testSwipingToDeleteALocalMockAsksFirst() {
        let screen = SentinelScreen.launch()
        screen.open()
        screen.openTool(ToolNames.apiMocking)

        screen.element("sentinel.apiMocking.new").tap()
        let nameField = screen.element("sentinel.apiMocking.name")
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "The editor didn't open")
        nameField.focus()
        nameField.typeText("Doomed")
        let patternField = screen.element("sentinel.apiMocking.pattern")
        patternField.focus()
        patternField.typeText("/doomed")
        screen.element("sentinel.apiMocking.save").tap()

        let row = screen.row("Doomed")
        // The row exists as soon as the mock is saved, while the editor sheet is still closing over it.
        XCTAssertTrue(screen.waitUntilHittable(row), "The mock wasn't saved")
        row.swipeLeft()
        let swipeDelete = screen.app.buttons["Delete"].firstMatch
        XCTAssertTrue(screen.waitUntilHittable(swipeDelete), "Swiping didn't show Delete")
        swipeDelete.tap()

        let confirmation = screen.app.alerts["Delete “Doomed”?"]
        XCTAssertTrue(confirmation.waitForExistence(timeout: 5), "Deleting didn't ask first")
        XCTAssertTrue(row.exists, "The mock was deleted before confirming")
        confirmation.buttons["Delete"].tap()

        XCTAssertTrue(screen.waitUntilGone(row), "The mock is still listed")
    }
}

// MARK: - Helpers

private extension APIMockingUITests {

    func switchOnRepositoryMock(in screen: SentinelScreen) {
        let group = screen.element("sentinel.apiMocking.group.Repository")
        XCTAssertTrue(group.waitForExistence(timeout: 5), "No Repository group")
        group.tap()
        let toggle = screen.element("sentinel.toggle.Repository")
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), "The group didn't expand")
        toggle.tapSwitch()
    }

    /// Closes Sentinel, fetches the repository from the example app's menu and returns what the menu shows.
    func fetchRepository(in screen: SentinelScreen) -> String {
        screen.dismiss()
        screen.app.buttons["Menu"].tap()
        let fetchButton = screen.app.buttons["Fetch repository"]
        XCTAssertTrue(fetchButton.waitForExistence(timeout: 5), "No Fetch repository button")
        fetchButton.tap()
        let result = screen.text(containing: "200:")
        XCTAssertTrue(result.waitForExistence(timeout: 10), "The request didn't come back with a 200")
        return result.label
    }
}
