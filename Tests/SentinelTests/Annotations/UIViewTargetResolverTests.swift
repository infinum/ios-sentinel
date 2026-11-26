//
//  UIViewTargetResolverTests.swift
//  SentinelTests
//

#if canImport(UIKit)

import UIKit
import XCTest
@testable import Sentinel

final class UIViewTargetResolverTests: XCTestCase {

    private var window: UIWindow!
    private var resolver: UIViewTargetResolver!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.isHidden = false
        resolver = UIViewTargetResolver()
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        resolver = nil
        super.tearDown()
    }

    func testResolvePicksTheLabelUnderTheTap() {
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
        label.text = "Total"
        label.accessibilityIdentifier = "totalLabel"
        window.addSubview(label)

        let resolved = resolver.resolve(root: window, at: CGPoint(x: 50, y: 20))

        XCTAssertEqual(resolved?.node.type, "UILabel")
        XCTAssertEqual(resolved?.node.accessibilityIdentifier, "totalLabel")
        XCTAssertEqual(resolved?.node.text, "Total")
        XCTAssertEqual(resolved?.toolkit, .uiKit)
        XCTAssertTrue(resolved?.handle === label)
    }

    /// An anonymous wrapper must not outrank the content inside it, and it must still be
    /// reachable by broadening.
    func testAnonymousContainerIsNotSelectedOutrightButCanBeBroadenedTo() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        label.text = "Inside"
        container.addSubview(label)
        window.addSubview(container)

        let resolved = resolver.resolve(root: window, at: CGPoint(x: 50, y: 50))
        XCTAssertEqual(resolved?.node.type, "UILabel")

        let broadened = TargetSelection.stepUp(from: try! XCTUnwrap(resolved?.node))
        XCTAssertEqual(broadened?.type, "UIView")
    }

    func testHiddenViewsAreNotResolved() {
        let hidden = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        hidden.text = "Hidden"
        hidden.isHidden = true
        window.addSubview(hidden)

        let resolved = resolver.resolve(root: window, at: CGPoint(x: 50, y: 50))

        XCTAssertNotEqual(resolved?.node.type, "UILabel")
    }

    /// The export payload is POSTed to an external endpoint, so a secure field's contents must
    /// never reach it. The developer-authored placeholder is safe.
    func testSecureTextFieldContributesItsPlaceholderNotItsContents() {
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        field.isSecureTextEntry = true
        field.text = "hunter2"
        field.placeholder = "Password"
        field.accessibilityIdentifier = "passwordField"
        window.addSubview(field)

        let resolved = resolver.resolve(root: window, at: CGPoint(x: 50, y: 20))

        XCTAssertEqual(resolved?.node.accessibilityIdentifier, "passwordField")
        XCTAssertEqual(resolved?.node.text, "Password")
        XCTAssertNotEqual(resolved?.node.text, "hunter2")
    }

    func testPlainTextFieldContributesItsLiveContents() {
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        field.text = "ada@example.com"
        window.addSubview(field)

        let resolved = resolver.resolve(root: window, at: CGPoint(x: 50, y: 20))

        XCTAssertEqual(resolved?.node.text, "ada@example.com")
    }

    func testResolveReturnsNilForATapOutsideTheWindow() {
        XCTAssertNil(resolver.resolve(root: window, at: CGPoint(x: 1000, y: 1000)))
    }

    func testRebindAcceptsAMatchingIdentifierAtTheSamePoint() {
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
        label.text = "Total"
        label.accessibilityIdentifier = "totalLabel"
        window.addSubview(label)

        let annotation = SentinelAnnotation(
            note: "note",
            toolkit: .uiKit,
            targetType: "UILabel",
            targetPath: "UIWindow>UILabel",
            accessibilityIdentifier: "totalLabel",
            rebindPoint: CGPoint(x: 50, y: 20)
        )

        XCTAssertTrue(resolver.rebind(annotation, root: window)?.handle === label)
    }

    func testRebindRejectsADifferentIdentifierAtTheSamePoint() {
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
        label.accessibilityIdentifier = "otherLabel"
        label.text = "Total"
        window.addSubview(label)

        let annotation = SentinelAnnotation(
            note: "note",
            toolkit: .uiKit,
            targetType: "UILabel",
            targetPath: "UIWindow>UILabel",
            accessibilityIdentifier: "totalLabel",
            rebindPoint: CGPoint(x: 50, y: 20)
        )

        XCTAssertNil(resolver.rebind(annotation, root: window))
    }

    func testRebindRejectsADifferentType() {
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
        label.text = "Total"
        window.addSubview(label)

        let annotation = SentinelAnnotation(
            note: "note",
            toolkit: .uiKit,
            targetType: "UIButton",
            targetPath: "UIWindow>UIButton",
            rebindPoint: CGPoint(x: 50, y: 20)
        )

        XCTAssertNil(resolver.rebind(annotation, root: window))
    }

    /// With no identifier to match on, text is the fallback identity check.
    func testRebindFallsBackToTextWhenThereIsNoIdentifier() {
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
        label.text = "Changed"
        window.addSubview(label)

        let annotation = SentinelAnnotation(
            note: "note",
            toolkit: .uiKit,
            targetType: "UILabel",
            targetPath: "UIWindow>UILabel",
            text: "Total",
            rebindPoint: CGPoint(x: 50, y: 20)
        )

        XCTAssertNil(resolver.rebind(annotation, root: window))

        label.text = "Total"
        XCTAssertTrue(resolver.rebind(annotation, root: window)?.handle === label)
    }

    /// A field that resolved on neither side must never orphan a note.
    func testRebindStaysPermissiveWhenNeitherSideResolvedALocator() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer())
        window.addSubview(view)

        let annotation = SentinelAnnotation(
            note: "note",
            toolkit: .uiKit,
            targetType: "UIView",
            targetPath: "UIWindow>UIView",
            rebindPoint: CGPoint(x: 50, y: 50)
        )

        XCTAssertTrue(resolver.rebind(annotation, root: window)?.handle === view)
    }

    /// A button's `titleLabel` is a subview, and selecting it instead of the button is never
    /// what the user meant.
    func testTappingAButtonSelectsTheButtonNotItsTitleLabel() throws {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        button.setTitle("Submit", for: .normal)
        button.accessibilityIdentifier = "submitButton"
        window.addSubview(button)
        window.layoutIfNeeded()

        let resolved = try XCTUnwrap(resolver.resolve(root: window, at: CGPoint(x: 100, y: 22)))

        XCTAssertEqual(resolved.node.type, "UIButton")
        XCTAssertEqual(resolved.node.accessibilityIdentifier, "submitButton")
        XCTAssertEqual(resolved.node.text, "Submit")
        XCTAssertTrue(resolved.handle === button)
    }

    func testOrdinalIsReportedForEachOfTwoSameTypeControls() throws {
        let top = UIButton(type: .system)
        top.frame = CGRect(x: 10, y: 100, width: 200, height: 44)
        top.setTitle("Pay now", for: .normal)
        top.accessibilityIdentifier = "payButton"

        let bottom = UIButton(type: .system)
        bottom.frame = CGRect(x: 10, y: 200, width: 200, height: 44)
        bottom.setTitle("Pay later", for: .normal)
        bottom.accessibilityIdentifier = "payLaterButton"

        window.addSubview(top)
        window.addSubview(bottom)
        window.layoutIfNeeded()

        let first = try XCTUnwrap(resolver.resolve(root: window, at: CGPoint(x: 100, y: 120)))
        XCTAssertEqual(first.node.accessibilityIdentifier, "payButton")
        let firstPosition = TargetSelection.ordinal(of: first.node, in: first.root)
        XCTAssertEqual(firstPosition.count, 2)
        XCTAssertEqual(firstPosition.ordinal, 1, "the topmost of two buttons is the first")

        let second = try XCTUnwrap(resolver.resolve(root: window, at: CGPoint(x: 100, y: 220)))
        XCTAssertEqual(second.node.accessibilityIdentifier, "payLaterButton")
        let secondPosition = TargetSelection.ordinal(of: second.node, in: second.root)
        XCTAssertEqual(secondPosition.count, 2)
        XCTAssertEqual(secondPosition.ordinal, 2)
    }

    /// A tree's nodes are built lazily and therefore at different moments, so every position it
    /// reports has to be read live. With frames captured at construction, a layout change between
    /// selecting an element and recording its ordinal made two same-type siblings both report
    /// "2 of 2".
    func testOrdinalUsesCurrentPositionsRatherThanOnesCapturedEarlier() throws {
        let top = UIButton(type: .system)
        top.frame = CGRect(x: 10, y: 100, width: 200, height: 44)
        top.accessibilityIdentifier = "topButton"

        let bottom = UIButton(type: .system)
        bottom.frame = CGRect(x: 10, y: 200, width: 200, height: 44)
        bottom.accessibilityIdentifier = "bottomButton"

        window.addSubview(top)
        window.addSubview(bottom)

        let resolved = try XCTUnwrap(resolver.resolve(root: window, at: CGPoint(x: 100, y: 120)))
        XCTAssertEqual(resolved.node.accessibilityIdentifier, "topButton")
        XCTAssertEqual(TargetSelection.ordinal(of: resolved.node, in: resolved.root).ordinal, 1)

        // The app relays out: what was the lower button is now the upper one.
        bottom.frame = CGRect(x: 10, y: 10, width: 200, height: 44)

        let position = TargetSelection.ordinal(of: resolved.node, in: resolved.root)
        XCTAssertEqual(position.count, 2)
        XCTAssertEqual(position.ordinal, 2, "the selection is now the lower of the two")
    }

    /// Sentinel's own overlay chrome covers the whole screen and has no children, so leaving it
    /// in the tree would make it the deepest hit for every tap.
    func testSentinelOwnOverlayIsExcludedFromTheTree() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        label.text = "App content"
        window.addSubview(label)
        window.addSubview(AnnotationOverlayView())
        window.subviews.last?.frame = window.bounds

        let resolved = resolver.resolve(root: window, at: CGPoint(x: 50, y: 50))

        XCTAssertEqual(resolved?.node.type, "UILabel")
    }
}

#endif
