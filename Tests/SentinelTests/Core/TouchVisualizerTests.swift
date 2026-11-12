//
//  TouchVisualizerTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.11.2026..
//

#if os(iOS)

import Testing
import UIKit
@testable import Sentinel

@Suite("Touch visualizer")
@MainActor
struct TouchVisualizerTests {

    private let isolatedDefaults = IsolatedUserDefaults()
    private let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
    // Only its identity is used, as a stand-in for a `UITouch`.
    private let touch = NSObject()

    private var touchID: ObjectIdentifier {
        ObjectIdentifier(touch)
    }

    // MARK: - Persistence

    @Test("Show touches is off by default")
    func offByDefault() {
        #expect(!TouchVisualizer(userDefaults: isolatedDefaults.defaults).isEnabled)
    }

    @Test("Turning it on is remembered across launches")
    func enabledStatePersists() {
        TouchVisualizer(userDefaults: isolatedDefaults.defaults).isEnabled = true

        #expect(TouchVisualizer(userDefaults: isolatedDefaults.defaults).isEnabled)
    }

    @Test("Turning it off is remembered across launches")
    func disabledStatePersists() {
        let visualizer = TouchVisualizer(userDefaults: isolatedDefaults.defaults)
        visualizer.isEnabled = true
        visualizer.isEnabled = false

        #expect(!TouchVisualizer(userDefaults: isolatedDefaults.defaults).isEnabled)
    }

    // MARK: - Indicators

    @Test("A touch that begins adds an indicator under the finger")
    func beganAddsIndicator() throws {
        let visualizer = TouchVisualizer(userDefaults: isolatedDefaults.defaults)

        visualizer.handleTouch(
            touchID,
            phase: .began,
            at: CGPoint(x: 100, y: 200),
            in: window
        )

        let indicator = try #require(visualizer.indicator(for: touchID))
        #expect(indicator.superview === window)
        #expect(indicator.center == CGPoint(x: 100, y: 200))
        #expect(!indicator.isUserInteractionEnabled)
    }

    @Test("The indicator follows a moving touch")
    func movedMovesIndicator() throws {
        let visualizer = TouchVisualizer(userDefaults: isolatedDefaults.defaults)
        visualizer.handleTouch(
            touchID,
            phase: .began,
            at: CGPoint(x: 100, y: 200),
            in: window
        )

        visualizer.handleTouch(
            touchID,
            phase: .moved,
            at: CGPoint(x: 150, y: 250),
            in: window
        )

        #expect(try #require(visualizer.indicator(for: touchID)).center == CGPoint(x: 150, y: 250))
    }

    @Test("A touch that ends or is cancelled stops being tracked", arguments: [UITouch.Phase.ended, .cancelled])
    func endedStopsTracking(phase: UITouch.Phase) {
        let visualizer = TouchVisualizer(userDefaults: isolatedDefaults.defaults)
        visualizer.handleTouch(
            touchID,
            phase: .began,
            at: .zero,
            in: window
        )

        visualizer.handleTouch(
            touchID,
            phase: phase,
            at: .zero,
            in: window
        )

        #expect(visualizer.indicator(for: touchID) == nil)
    }

    @Test("A touch that begins again replaces its indicator instead of leaving the old one behind")
    func beganTwiceReplacesIndicator() throws {
        let visualizer = TouchVisualizer(userDefaults: isolatedDefaults.defaults)
        visualizer.handleTouch(
            touchID,
            phase: .began,
            at: .zero,
            in: window
        )
        let first = try #require(visualizer.indicator(for: touchID))

        visualizer.handleTouch(
            touchID,
            phase: .began,
            at: .zero,
            in: window
        )

        #expect(first.superview == nil)
        #expect(window.subviews.count == 1)
    }

    @Test("Each finger gets its own indicator")
    func multipleTouches() {
        let visualizer = TouchVisualizer(userDefaults: isolatedDefaults.defaults)
        let secondTouch = NSObject()
        visualizer.handleTouch(
            touchID,
            phase: .began,
            at: CGPoint(x: 10, y: 10),
            in: window
        )
        visualizer.handleTouch(
            ObjectIdentifier(secondTouch),
            phase: .began,
            at: CGPoint(x: 20, y: 20),
            in: window
        )

        #expect(window.subviews.count == 2)
        #expect(visualizer.indicator(for: ObjectIdentifier(secondTouch))?.center == CGPoint(x: 20, y: 20))
    }

    @Test("Moving or ending a touch it never saw begin does nothing")
    func unknownTouchIsIgnored() {
        let visualizer = TouchVisualizer(userDefaults: isolatedDefaults.defaults)

        visualizer.handleTouch(
            touchID,
            phase: .moved,
            at: .zero,
            in: window
        )
        visualizer.handleTouch(
            touchID,
            phase: .ended,
            at: .zero,
            in: window
        )

        #expect(window.subviews.isEmpty)
    }

    @Test("Turning it off removes the indicators of touches in progress")
    func disablingRemovesIndicators() {
        let visualizer = TouchVisualizer(userDefaults: isolatedDefaults.defaults)
        visualizer.isEnabled = true
        visualizer.handleTouch(
            touchID,
            phase: .began,
            at: .zero,
            in: window
        )

        visualizer.isEnabled = false

        #expect(window.subviews.isEmpty)
        #expect(visualizer.indicator(for: touchID) == nil)
    }
}

#endif
