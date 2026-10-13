//
//  SentinelScreen.swift
//  Example-iOSUITests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import XCTest

/// Drives the example app and the Sentinel screen on top of it.
@MainActor
struct SentinelScreen {

    static let tabTitles = ["Device", "Application", "Tools", "Preferences", "Performance"]

    let app: XCUIApplication

    /// Launches the example app. `resetState` wipes user defaults and saved crashes first; leave it
    /// out when relaunching to check that something persisted.
    @discardableResult
    static func launch(resetState: Bool = true) -> SentinelScreen {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"] + (resetState ? ["-resetState"] : [])
        app.launch()
        return SentinelScreen(app: app)
    }

    // MARK: - Example app

    var openButton: XCUIElement { app.buttons["example.openSentinel"] }

    func open(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(
            openButton.waitForExistence(timeout: 5),
            "The example app isn't showing",
            file: file,
            line: line
        )
        openButton.tap()
        XCTAssertTrue(
            tabBar.waitForExistence(timeout: 5),
            "Sentinel didn't open",
            file: file,
            line: line
        )
    }

    /// Swipes the Sentinel sheet away.
    func dismiss(file: StaticString = #filePath, line: UInt = #line) {
        app.navigationBars.firstMatch.swipeDown(velocity: .fast)
        XCTAssertTrue(
            waitUntilHittable(openButton),
            "Sentinel didn't close",
            file: file,
            line: line
        )
    }

    // MARK: - Sentinel

    var tabBar: XCUIElement { app.tabBars.firstMatch }

    func tab(_ title: String) -> XCUIElement {
        tabBar.buttons[title]
    }

    func selectTab(_ title: String) {
        tab(title).tap()
    }

    func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    func row(_ title: String) -> XCUIElement {
        element("sentinel.row.\(title)")
    }

    func openTool(_ name: String, file: StaticString = #filePath, line: UInt = #line) {
        selectTab("Tools")
        let toolRow = row(name)
        XCTAssertTrue(
            toolRow.waitForExistence(timeout: 5),
            "No row for \(name)",
            file: file,
            line: line
        )
        toolRow.tap()
    }

    func goBack() {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func search(for text: String, file: StaticString = #filePath, line: UInt = #line) {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 5),
            "No search field",
            file: file,
            line: line
        )
        searchField.focus()
        let clearButton = searchField.buttons["Clear text"]
        if clearButton.exists {
            clearButton.tap()
        }
        searchField.typeText(text)
    }

    func text(containing value: String) -> XCUIElement {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", value)).firstMatch
    }

    func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true AND hittable == true"),
            object: element
        )
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    func waitUntilGone(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}

extension XCUIElement {

    var hasKeyboardFocus: Bool {
        (value(forKey: "hasKeyboardFocus") as? Bool) ?? false
    }

    /// Taps until the element takes keyboard focus; a tap that lands mid-transition is otherwise lost.
    func focus() {
        for _ in 0..<3 where !hasKeyboardFocus {
            tap()
            _ = XCTWaiter().wait(
                for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "hasKeyboardFocus == true"), object: self)],
                timeout: 2
            )
        }
    }

    /// Replaces the text of a text field or text view.
    func replaceText(with text: String) {
        focus()
        let currentValue = (value as? String) ?? ""
        typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count))
        typeText(text)
    }

    /// Taps the switch itself; tapping the middle of a SwiftUI toggle row hits its label.
    func tapSwitch() {
        // Some iOS versions expose the switch as a child of the identified toggle, others as the toggle itself.
        let innerSwitch = switches.firstMatch
        if innerSwitch.exists {
            innerSwitch.tap()
        } else {
            coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        }
    }

    /// Waits until `value` is no longer `oldValue`.
    func waitForValueChange(from oldValue: String?, timeout: TimeInterval = 3) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value != %@", oldValue ?? ""),
            object: self
        )
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
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
    static let apiMocking = "API Mocking"
    static let pulse = "Pulse"
    static let macConnection = "Connect to Mac"

    static let all = [
        userDefaults,
        baseURL,
        colorChange,
        crashDetection,
        clearAppData,
        customLocation,
        apiMocking,
        pulse,
        macConnection
    ]
}
