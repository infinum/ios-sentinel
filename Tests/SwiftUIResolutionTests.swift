//
//  SwiftUIResolutionTests.swift
//  SentinelTests
//

#if canImport(UIKit)

import SwiftUI
import UIKit
import XCTest
@testable import Sentinel

/// Pins down what a tap inside a SwiftUI hierarchy actually resolves to.
///
/// These tests encode a platform limitation, not a preference: SwiftUI draws `Text` and `Button`
/// itself and produces no backing view for them, so there is nothing deeper to resolve to. If a
/// future SwiftUI release starts exposing per-view backing views or an always-available element
/// tree, these tests are the ones that will fail and say so.
final class SwiftUIResolutionTests: XCTestCase {

    private var window: UIWindow!
    private var resolver: UIViewTargetResolver!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        resolver = UIViewTargetResolver()
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        resolver = nil
        super.tearDown()
    }

    func testATapOnSwiftUIDrawnContentResolvesToTheHostingViewAndNamesTheAppsViewType() throws {
        let controller = UIHostingController(rootView: TextOnlyScreen())
        show(controller)

        let resolved = try XCTUnwrap(resolver.resolve(root: window, at: CGPoint(x: 160, y: 240)))

        XCTAssertEqual(resolved.toolkit, .swiftUI)
        XCTAssertEqual(resolved.node.type, "_UIHostingView")
        // The locator that actually matters: the app's own view type, so an agent knows the file.
        XCTAssertEqual(resolved.node.swiftUIType, "TextOnlyScreen")
    }

    /// SwiftUI bridges some controls to real UIKit ones. Those resolve properly, and are still
    /// reported as SwiftUI because that is the code the fix belongs in.
    func testABridgedUIKitControlResolvesToTheControlButStaysTaggedAsSwiftUI() throws {
        let controller = UIHostingController(rootView: ToggleScreen())
        show(controller)

        let switchView = try XCTUnwrap(firstSwitch(in: window))
        let center = CGPoint(x: switchView.sentinelScreenFrame.midX, y: switchView.sentinelScreenFrame.midY)

        let resolved = try XCTUnwrap(resolver.resolve(root: window, at: center))

        XCTAssertEqual(resolved.node.type, "UISwitch")
        XCTAssertEqual(resolved.toolkit, .swiftUI)
        XCTAssertEqual(resolved.node.swiftUIType, "ToggleScreen")
    }

    /// A `UISwitch` is eight levels of private UIKit views. Selecting one of those would be
    /// useless to an agent and would need four broadening taps to escape.
    func testAControlIsWalkedAsALeafSoItsPrivateInternalsAreNeverSelected() throws {
        let controller = UIHostingController(rootView: ToggleScreen())
        show(controller)

        let switchView = try XCTUnwrap(firstSwitch(in: window))
        XCTAssertFalse(switchView.subviews.isEmpty, "the control really does have internals")

        let center = CGPoint(x: switchView.sentinelScreenFrame.midX, y: switchView.sentinelScreenFrame.midY)
        let resolved = try XCTUnwrap(resolver.resolve(root: window, at: center))

        XCTAssertTrue(resolved.view === switchView)
        XCTAssertTrue(resolved.node.children.isEmpty)
    }

    /// A `UIViewRepresentable` is the one case where SwiftUI hands over an app-owned type name
    /// for the element itself rather than for the screen several levels above it.
    func testARepresentableIsNamedByItsOwnTypeRatherThanTheRootView() throws {
        let controller = UIHostingController(rootView: RepresentableScreen())
        show(controller)

        let resolved = try XCTUnwrap(resolver.resolve(root: window, at: CGPoint(x: 160, y: 240)))

        XCTAssertEqual(resolved.node.type, "UILabel")
        XCTAssertEqual(resolved.node.accessibilityIdentifier, "legacyLabel")
        XCTAssertEqual(resolved.toolkit, .swiftUI)
        XCTAssertEqual(resolved.node.swiftUIType, "LegacyLabel")
    }

    // MARK: - Helpers

    private func show(_ controller: UIViewController) {
        window.rootViewController = controller
        window.isHidden = false
        window.layoutIfNeeded()
        controller.view.layoutIfNeeded()
    }

    private func firstSwitch(in view: UIView) -> UISwitch? {
        if let found = view as? UISwitch { return found }
        for subview in view.subviews {
            if let found = firstSwitch(in: subview) { return found }
        }
        return nil
    }
}

// MARK: - Sample screens

private struct TextOnlyScreen: View {

    var body: some View {
        Text("Total")
            .accessibilityIdentifier("totalText")
    }
}

private struct ToggleScreen: View {

    var body: some View {
        Toggle("Feature flag", isOn: .constant(true))
            .accessibilityIdentifier("featureFlagToggle")
    }
}

private struct RepresentableScreen: View {

    var body: some View {
        LegacyLabel()
            .frame(width: 320, height: 480)
    }
}

private struct LegacyLabel: UIViewRepresentable {

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.text = "Legacy"
        label.accessibilityIdentifier = "legacyLabel"
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {}
}

#endif
