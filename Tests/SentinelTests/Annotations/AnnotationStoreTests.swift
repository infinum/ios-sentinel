//
//  AnnotationStoreTests.swift
//  SentinelTests
//

#if canImport(UIKit)

import UIKit
import XCTest
@testable import Sentinel

final class AnnotationStoreTests: XCTestCase {

    private var store: AnnotationStore!

    override func setUp() {
        super.setUp()
        // The store is a process-lifetime singleton, so each test starts from a known state.
        store = .shared
        store.clear()
        store.isCaptureActive = false
    }

    override func tearDown() {
        store.clear()
        store.isCaptureActive = false
        store = nil
        super.tearDown()
    }

    func testAddAssignsAnID() {
        let stored = store.add(makeAnnotation(note: "too small"), target: nil)

        XCTAssertFalse(stored.id.isEmpty)
        XCTAssertEqual(store.annotations.count, 1)
        XCTAssertEqual(store.annotations.first?.id, stored.id)
    }

    func testAddKeepsAnIDThatWasAlreadySet() {
        let stored = store.add(makeAnnotation(id: "fixed", note: "keep"), target: nil)

        XCTAssertEqual(stored.id, "fixed")
    }

    func testGeneratedIDsAreUnique() {
        (0..<100).forEach { _ in store.add(makeAnnotation(note: "note"), target: nil) }

        XCTAssertEqual(Set(store.annotations.map(\.id)).count, 100)
    }

    func testUpdateNoteReplacesOnlyThatNote() {
        let first = store.add(makeAnnotation(note: "first"), target: nil)
        let second = store.add(makeAnnotation(note: "second"), target: nil)

        store.updateNote(id: first.id, note: "edited")

        XCTAssertEqual(store.annotations.first(where: { $0.id == first.id })?.note, "edited")
        XCTAssertEqual(store.annotations.first(where: { $0.id == second.id })?.note, "second")
    }

    func testRemoveDropsTheNoteAndItsTarget() {
        let view = UIView()
        let stored = store.add(makeAnnotation(note: "gone"), target: view)

        store.remove(id: stored.id)

        XCTAssertTrue(store.annotations.isEmpty)
        XCTAssertNil(store.target(for: stored.id))
    }

    func testMarkSentFlagsOnlyTheListedNotes() {
        let first = store.add(makeAnnotation(note: "first"), target: nil)
        let second = store.add(makeAnnotation(note: "second"), target: nil)

        store.markSent(ids: [first.id])

        XCTAssertEqual(store.annotations.first(where: { $0.id == first.id })?.isSent, true)
        XCTAssertEqual(store.annotations.first(where: { $0.id == second.id })?.isSent, false)
    }

    func testClearRemovesEverything() {
        store.add(makeAnnotation(note: "a"), target: UIView())
        store.add(makeAnnotation(note: "b"), target: UIView())

        store.clear()

        XCTAssertTrue(store.annotations.isEmpty)
    }

    /// The whole reason the live handle lives in the store rather than in the annotation: a note
    /// outlives the screen it was taken on, and must not keep that screen's views alive.
    func testTargetIsHeldWeakly() {
        var view: UIView? = UIView()
        let stored = store.add(makeAnnotation(note: "weak"), target: view)
        XCTAssertNotNil(store.target(for: stored.id))

        view = nil

        XCTAssertNil(store.target(for: stored.id))
        XCTAssertEqual(store.annotations.count, 1, "the note itself must survive its view")
    }

    func testBindRepointsANoteAtAFreshView() {
        let stored = store.add(makeAnnotation(note: "rebind"), target: nil)
        let replacement = UIView()

        store.bind(id: stored.id, to: replacement)

        XCTAssertTrue(store.target(for: stored.id) === replacement)
    }

    // MARK: - Helpers

    private func makeAnnotation(id: String = "", note: String) -> SentinelAnnotation {
        SentinelAnnotation(
            id: id,
            note: note,
            toolkit: .uiKit,
            targetType: "UILabel",
            targetPath: "UIView>UILabel"
        )
    }
}

#endif
