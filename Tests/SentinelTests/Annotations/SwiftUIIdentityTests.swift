//
//  SwiftUIIdentityTests.swift
//  SentinelTests
//

#if canImport(UIKit)

import SwiftUI
import UIKit
import XCTest
@testable import Sentinel

final class SwiftUIIdentityTests: XCTestCase {

    func testAppTypeIsRecoveredFromAHostingViewName() {
        let name = "SwiftUI._UIHostingView<Example_iOS.CheckoutScreen>"

        XCTAssertEqual(SwiftUIIdentity.appTypeName(in: name), "CheckoutScreen")
    }

    func testAppTypeIsFoundThroughNestedModifierWrappers() {
        let name = "SwiftUI._UIHostingView<SwiftUI.ModifiedContent<Example_iOS.CheckoutScreen, SwiftUI._PaddingLayout>>"

        XCTAssertEqual(SwiftUIIdentity.appTypeName(in: name), "CheckoutScreen")
    }

    func testAppTypeSkipsFrameworkArgumentsAndPicksTheAppsOwn() {
        let name = "SwiftUI._UIHostingView<SwiftUI.ModifiedContent<SwiftUI.EmptyView, Example_iOS.Overlay>>"

        XCTAssertEqual(SwiftUIIdentity.appTypeName(in: name), "Overlay")
    }

    /// Naming `AnyView` would tell an agent nothing, so nothing is reported at all.
    func testAppTypeIsNilWhenOnlyFrameworkTypesAreExposed() {
        XCTAssertNil(SwiftUIIdentity.appTypeName(in: "SwiftUI._UIHostingView<SwiftUI.AnyView>"))
    }

    func testAppTypeIsNilForAPlainFrameworkClass() {
        XCTAssertNil(SwiftUIIdentity.appTypeName(in: "SwiftUI.CGDrawingView"))
    }

    func testSimpleTypeNameDropsTheModulePrefixAndGenerics() {
        let controller = UIHostingController(rootView: EmptyView())

        XCTAssertEqual(SwiftUIIdentity.simpleTypeName(of: controller), "UIHostingController")
        XCTAssertEqual(SwiftUIIdentity.simpleTypeName(of: UILabel()), "UILabel")
    }

    /// `NSStringFromClass` reports a mangled name for a generic Swift class, which carries no
    /// parseable generic parameters at all — the reason the demangled name is used instead.
    func testQualifiedNameIsDemangledAndCarriesGenericParameters() {
        let controller = UIHostingController(rootView: SampleTestScreen())

        let qualified = SwiftUIIdentity.qualifiedName(of: controller)

        XCTAssertTrue(qualified.contains("UIHostingController<"), qualified)
        XCTAssertTrue(qualified.contains("SampleTestScreen"), qualified)
        XCTAssertFalse(NSStringFromClass(type(of: controller)).contains("<"))
    }

    func testHostingViewIsRecognised() {
        let controller = UIHostingController(rootView: EmptyView())

        XCTAssertTrue(SwiftUIIdentity.isHostingView(controller.view))
        XCTAssertFalse(SwiftUIIdentity.isHostingView(UIView()))
    }

    func testRootTypeNameIsFoundFromAViewInsideTheHostedHierarchy() {
        let controller = UIHostingController(rootView: SampleTestScreen())
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        controller.view.layoutIfNeeded()

        // Resolved from the hosting view itself, which is the ancestor every hosted view has.
        XCTAssertEqual(SwiftUIIdentity.rootTypeName(for: controller.view), "SampleTestScreen")
    }

    func testRootTypeNameIsNilForAPlainUIKitView() {
        XCTAssertNil(SwiftUIIdentity.rootTypeName(for: UIView()))
    }
}

// MARK: - Sample

private struct SampleTestScreen: View {

    var body: some View {
        Text("hello")
    }
}

#endif
