//
//  TargetSelectionTests.swift
//  SentinelTests
//

#if canImport(UIKit)

import XCTest
@testable import Sentinel

final class TargetSelectionTests: XCTestCase {

    func testDeepestPrefersTheLastChildBecauseItDrawsOnTop() {
        let back = FakeTargetNode(type: "Back", frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let front = FakeTargetNode(type: "Front", frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let root = FakeTargetNode(type: "Root", frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        root.attach([back, front])

        let hit = TargetSelection.deepest(in: root, at: CGPoint(x: 50, y: 50))

        XCTAssertEqual(hit?.type, "Front")
    }

    /// iOS 26 puts a full-screen, empty `FloatingBarContainerView` on top of a navigation
    /// container's content. It must not hide the content drawn underneath it.
    func testDeepestLooksPastATopSiblingThatHoldsNothingAnnotatable() {
        let fullScreen = CGRect(x: 0, y: 0, width: 100, height: 100)
        let label = FakeTargetNode(type: "Label", frame: CGRect(x: 10, y: 40, width: 80, height: 20))
        let content = FakeTargetNode(type: "Content", frame: fullScreen, isAnnotatable: false)
        content.attach([label])
        let floatingBarHost = FakeTargetNode(type: "FloatingBarHost", frame: fullScreen, isAnnotatable: false)
        let floatingBars = FakeTargetNode(type: "FloatingBars", frame: fullScreen, isAnnotatable: false)
        floatingBars.attach([floatingBarHost])
        let root = FakeTargetNode(type: "Root", frame: fullScreen)
        root.attach([content, floatingBars])

        XCTAssertEqual(TargetSelection.deepest(in: root, at: CGPoint(x: 50, y: 50))?.type, "Label")
    }

    func testDeepestKeepsTheTopmostHitWhenNoSiblingHoldsAnythingAnnotatable() {
        let fullScreen = CGRect(x: 0, y: 0, width: 100, height: 100)
        let back = FakeTargetNode(type: "Back", frame: fullScreen, isAnnotatable: false)
        let front = FakeTargetNode(type: "Front", frame: fullScreen, isAnnotatable: false)
        let root = FakeTargetNode(type: "Root", frame: fullScreen)
        root.attach([back, front])

        XCTAssertEqual(TargetSelection.deepest(in: root, at: CGPoint(x: 50, y: 50))?.type, "Front")
    }

    func testDeepestReturnsNilWhenThePointMissesTheRoot() {
        let root = FakeTargetNode(type: "Root", frame: CGRect(x: 0, y: 0, width: 10, height: 10))

        XCTAssertNil(TargetSelection.deepest(in: root, at: CGPoint(x: 50, y: 50)))
    }

    func testDeepestDescendsIntoTheChildContainingThePoint() {
        let left = FakeTargetNode(type: "Left", frame: CGRect(x: 0, y: 0, width: 50, height: 100))
        let right = FakeTargetNode(type: "Right", frame: CGRect(x: 50, y: 0, width: 50, height: 100))
        let root = FakeTargetNode(type: "Root", frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        root.attach([left, right])

        XCTAssertEqual(TargetSelection.deepest(in: root, at: CGPoint(x: 10, y: 10))?.type, "Left")
        XCTAssertEqual(TargetSelection.deepest(in: root, at: CGPoint(x: 90, y: 10))?.type, "Right")
    }

    func testNearestAnnotatableWalksUpPastNonAnnotatableNodes() {
        let leaf = FakeTargetNode(type: "Leaf", frame: .zero, isAnnotatable: false)
        let wrapper = FakeTargetNode(type: "Wrapper", frame: .zero, isAnnotatable: false)
        let card = FakeTargetNode(type: "Card", frame: .zero, isAnnotatable: true)
        card.attach([wrapper])
        wrapper.attach([leaf])

        XCTAssertEqual(TargetSelection.nearestAnnotatable(from: leaf)?.type, "Card")
    }

    func testNearestAnnotatableReturnsNilWhenNothingQualifies() {
        let leaf = FakeTargetNode(type: "Leaf", frame: .zero, isAnnotatable: false)

        XCTAssertNil(TargetSelection.nearestAnnotatable(from: leaf))
    }

    func testStepUpStopsAtABroadenableAncestorThatIsNotAnnotatable() {
        let leaf = FakeTargetNode(type: "Leaf", frame: .zero, isAnnotatable: true)
        let container = FakeTargetNode(type: "Container", frame: .zero, isAnnotatable: false, isBroadenable: true)
        container.attach([leaf])

        XCTAssertEqual(TargetSelection.stepUp(from: leaf)?.type, "Container")
    }

    func testStepUpReturnsNilAtTheOutermostNodeSoTheCallerCanWrapAround() {
        let leaf = FakeTargetNode(type: "Leaf", frame: .zero, isAnnotatable: true)
        let root = FakeTargetNode(type: "Root", frame: .zero, isAnnotatable: false, isBroadenable: false)
        root.attach([leaf])

        XCTAssertNil(TargetSelection.stepUp(from: leaf))
    }

    func testPathListsOnlyAnnotatableAncestorsBroadestFirst() {
        let leaf = FakeTargetNode(type: "UILabel", frame: .zero, isAnnotatable: true)
        let wrapper = FakeTargetNode(type: "UIView", frame: .zero, isAnnotatable: false)
        let button = FakeTargetNode(type: "UIButton", frame: .zero, isAnnotatable: true)
        let stack = FakeTargetNode(type: "UIStackView", frame: .zero, isAnnotatable: true)
        stack.attach([button])
        button.attach([wrapper])
        wrapper.attach([leaf])

        XCTAssertEqual(TargetSelection.path(of: leaf), "UIStackView>UIButton>UILabel")
    }

    func testRootWalksToTheOutermostNode() {
        let leaf = FakeTargetNode(type: "Leaf", frame: .zero)
        let middle = FakeTargetNode(type: "Middle", frame: .zero)
        let root = FakeTargetNode(type: "Root", frame: .zero)
        root.attach([middle])
        middle.attach([leaf])

        XCTAssertTrue(TargetSelection.root(of: leaf) === root)
    }

    func testOrdinalOrdersSameTypeNodesTopToBottomThenLeftToRight() {
        let bottom = FakeTargetNode(type: "UILabel", frame: CGRect(x: 0, y: 100, width: 10, height: 10))
        let topRight = FakeTargetNode(type: "UILabel", frame: CGRect(x: 50, y: 0, width: 10, height: 10))
        let topLeft = FakeTargetNode(type: "UILabel", frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let other = FakeTargetNode(type: "UIButton", frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let root = FakeTargetNode(type: "Root", frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        root.attach([bottom, topRight, topLeft, other])

        XCTAssertEqual(TargetSelection.ordinal(of: topLeft, in: root).ordinal, 1)
        XCTAssertEqual(TargetSelection.ordinal(of: topRight, in: root).ordinal, 2)
        XCTAssertEqual(TargetSelection.ordinal(of: bottom, in: root).ordinal, 3)
        XCTAssertEqual(TargetSelection.ordinal(of: topLeft, in: root).count, 3)
    }

    func testOrdinalIgnoresZeroSizedNodes() {
        let empty = FakeTargetNode(type: "UILabel", frame: .zero)
        let visible = FakeTargetNode(type: "UILabel", frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let root = FakeTargetNode(type: "Root", frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        root.attach([empty, visible])

        XCTAssertEqual(TargetSelection.ordinal(of: visible, in: root).count, 1)
    }

    /// The ordinal is found by identity, so counting against a tree the node does not belong to
    /// must not silently report a wrong position.
    func testOrdinalFallsBackToOneWhenTheNodeIsNotInTheTree() {
        let stranger = FakeTargetNode(type: "UILabel", frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let member = FakeTargetNode(type: "UILabel", frame: CGRect(x: 0, y: 20, width: 10, height: 10))
        let root = FakeTargetNode(type: "Root", frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        root.attach([member])

        let position = TargetSelection.ordinal(of: stranger, in: root)

        XCTAssertEqual(position.ordinal, 1)
        XCTAssertEqual(position.count, 1)
    }
}

// MARK: - Fake

private final class FakeTargetNode: TargetNode {

    let type: String
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    let text: String? = nil
    let swiftUIType: String? = nil
    let toolkit: AnnotationToolkit = .uiKit
    let isAnnotatable: Bool
    let isBroadenable: Bool
    let screenFrame: CGRect

    private(set) var children: [TargetNode] = []
    weak var parentNode: FakeTargetNode?
    var parent: TargetNode? { parentNode }

    init(type: String, frame: CGRect, isAnnotatable: Bool = true, isBroadenable: Bool? = nil) {
        self.type = type
        screenFrame = frame
        self.isAnnotatable = isAnnotatable
        self.isBroadenable = isBroadenable ?? isAnnotatable
    }

    func attach(_ nodes: [FakeTargetNode]) {
        children = nodes
        nodes.forEach { $0.parentNode = self }
    }
}

#endif
