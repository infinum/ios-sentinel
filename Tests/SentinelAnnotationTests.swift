//
//  SentinelAnnotationTests.swift
//  SentinelTests
//

#if canImport(UIKit)

import XCTest
@testable import Sentinel

final class SentinelAnnotationTests: XCTestCase {

    func testExportJSONCarriesEveryLocatorForAUIKitTarget() throws {
        let annotation = SentinelAnnotation(
            id: "a3k9x2m1",
            note: "button too small",
            toolkit: .uiKit,
            targetType: "UIButton",
            targetPath: "UIStackView>UIButton",
            accessibilityIdentifier: "submitButton",
            ordinal: 1,
            ordinalCount: 3,
            text: "Submit",
            screen: "CheckoutViewController"
        )

        let json = try object(from: annotation.exportJSON())

        XCTAssertEqual(json["id"] as? String, "a3k9x2m1")
        XCTAssertEqual(json["note"] as? String, "button too small")
        XCTAssertEqual(json["toolkit"] as? String, "uikit")
        XCTAssertEqual(json["targetType"] as? String, "UIButton")
        XCTAssertEqual(json["targetPath"] as? String, "UIStackView>UIButton")
        XCTAssertEqual(json["accessibilityIdentifier"] as? String, "submitButton")
        XCTAssertEqual(json["ordinal"] as? Int, 1)
        XCTAssertEqual(json["ordinalCount"] as? Int, 3)
        XCTAssertEqual(json["text"] as? String, "Submit")
        XCTAssertEqual(json["screen"] as? String, "CheckoutViewController")
    }

    func testExportJSONNamesTheAppViewTypeForASwiftUITarget() throws {
        let annotation = SentinelAnnotation(
            note: "wrong padding",
            toolkit: .swiftUI,
            targetType: "CGDrawingView",
            targetPath: "CGDrawingView",
            accessibilityIdentifier: "totalLabel",
            swiftUIType: "CheckoutScreen"
        )

        let json = try object(from: annotation.exportJSON())

        XCTAssertEqual(json["toolkit"] as? String, "swiftui")
        XCTAssertEqual(json["swiftUIType"] as? String, "CheckoutScreen")
    }

    /// An unresolved locator is written as an explicit `null`, so a routine can tell "looked for
    /// and not found" apart from "not part of this schema".
    func testUnresolvedLocatorsAreEncodedAsNullRatherThanOmitted() throws {
        let annotation = SentinelAnnotation(
            note: "note",
            toolkit: .uiKit,
            targetType: "UIView",
            targetPath: "UIView"
        )

        let json = try object(from: annotation.exportJSON())

        XCTAssertTrue(json.keys.contains("accessibilityIdentifier"))
        XCTAssertTrue(json["accessibilityIdentifier"] is NSNull)
        XCTAssertTrue(json["swiftUIType"] is NSNull)
        XCTAssertTrue(json["text"] is NSNull)
    }

    /// Rebind coordinates and the sent flag are Sentinel's own bookkeeping and would only be
    /// noise for the routine reading the batch.
    func testExportJSONOmitsInternalBookkeeping() throws {
        let annotation = SentinelAnnotation(
            note: "note",
            toolkit: .uiKit,
            targetType: "UIView",
            targetPath: "UIView",
            rebindPoint: CGPoint(x: 12, y: 34),
            isSent: true
        )

        let json = try object(from: annotation.exportJSON())

        XCTAssertNil(json["rebindPoint"])
        XCTAssertNil(json["isSent"])
    }

    func testBatchExportProducesAnArray() throws {
        let annotations = [
            SentinelAnnotation(id: "one", note: "a", toolkit: .uiKit, targetType: "UIView", targetPath: "UIView"),
            SentinelAnnotation(id: "two", note: "b", toolkit: .uiKit, targetType: "UIView", targetPath: "UIView")
        ]

        let json = try SentinelAnnotation.exportJSON(for: annotations)
        let decoded = try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [[String: Any]]

        XCTAssertEqual(decoded?.count, 2)
        XCTAssertEqual(decoded?.first?["id"] as? String, "one")
    }

    // MARK: - Helpers

    private func object(from json: String) throws -> [String: Any] {
        let decoded = try JSONSerialization.jsonObject(with: Data(json.utf8))
        let array = try XCTUnwrap(decoded as? [[String: Any]])
        return try XCTUnwrap(array.first)
    }
}

#endif
