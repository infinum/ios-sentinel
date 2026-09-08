//
//  AnnotationOverlayViewTests.swift
//  SentinelTests
//

#if canImport(UIKit)

import UIKit
import XCTest
@testable import Sentinel

/// The overlay's touch routing is what decides whether the host app stays usable while notes
/// are on screen, so it is pinned down here rather than left to manual testing.
final class AnnotationOverlayViewTests: XCTestCase {

    private var window: UIWindow!
    private var overlay: AnnotationOverlayView!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        overlay = AnnotationOverlayView()
        overlay.frame = window.bounds
        window.addSubview(overlay)
        window.isHidden = false
    }

    override func tearDown() {
        window.isHidden = true
        overlay = nil
        window = nil
        super.tearDown()
    }

    func testCaptureModeConsumesEveryTouch() {
        overlay.isCaptureActive = true

        XCTAssertTrue(overlay.point(inside: CGPoint(x: 5, y: 5), with: nil))
        XCTAssertTrue(overlay.point(inside: CGPoint(x: 300, y: 400), with: nil))
    }

    /// The whole point of passive mode: saved notes stay visible and editable while the app
    /// underneath keeps working.
    func testPassiveModeRefusesTouchesThatMissABadge() {
        overlay.isCaptureActive = false
        overlay.markers = [marker(number: 1, frame: CGRect(x: 100, y: 100, width: 80, height: 40))]

        XCTAssertFalse(overlay.point(inside: CGPoint(x: 5, y: 5), with: nil))
        // Inside the outlined element, but outside its badge — still passes through.
        XCTAssertFalse(overlay.point(inside: CGPoint(x: 170, y: 135), with: nil))
    }

    func testPassiveModeConsumesATouchOnABadge() {
        overlay.isCaptureActive = false
        overlay.markers = [marker(number: 1, frame: CGRect(x: 100, y: 100, width: 80, height: 40))]

        // The badge is drawn as a square at the element's top-left corner.
        XCTAssertTrue(overlay.point(inside: CGPoint(x: 105, y: 105), with: nil))
    }

    func testWithNoMarkersPassiveModeRefusesEverything() {
        overlay.isCaptureActive = false
        overlay.markers = []

        XCTAssertFalse(overlay.point(inside: CGPoint(x: 160, y: 240), with: nil))
    }

    /// The overlay must never resolve as its own annotation target.
    func testTheOverlayIsMarkedAsSentinelChrome() {
        XCTAssertTrue(overlay is SentinelOverlayView)
        XCTAssertTrue(AnnotationInspectCard() is SentinelOverlayView)
        XCTAssertTrue(AnnotationStopButton() is SentinelOverlayView)
    }

    // MARK: - Helpers

    private func marker(number: Int, frame: CGRect) -> AnnotationMarker {
        AnnotationMarker(
            number: number,
            screenFrame: frame,
            annotation: SentinelAnnotation(
                id: "id\(number)",
                note: "note",
                toolkit: .uiKit,
                targetType: "UILabel",
                targetPath: "UILabel"
            )
        )
    }
}

#endif
