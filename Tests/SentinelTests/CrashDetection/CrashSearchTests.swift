//
//  CrashSearchTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.11.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Crash search")
struct CrashSearchTests {

    private let searchable = CrashModel.Searchable(
        crash: CrashModel(
            type: .nsexception,
            details: CrashModel.Details(
                name: "NSRangeException: index 7 beyond bounds",
                date: Date(timeIntervalSince1970: 1_790_000_000),
                deviceInfo: DeviceTool.Info()
            ),
            traces: [
                CrashModel.StackTrace(
                    title: "0   CoreFoundation   0x0000000180a3d1f4 __exceptionPreprocess + 164",
                    detail: ""
                ),
                CrashModel.StackTrace(
                    title: "1   Example-iOS   0x0000000102684abc $s11Example_iOS14FeedDataSourceC4itemyyF + 212",
                    detail: ""
                ),
                CrashModel.StackTrace(
                    title: "2   Example-iOS   0x0000000102684def $s9876WidgetC4loadyyF + 8",
                    detail: ""
                ),
                CrashModel.StackTrace(
                    title: "3   libcommonCrypto.dylib   0x00000001a0b1c2d4 CC_SHA256 + 40",
                    detail: ""
                )
            ]
        )
    )

    @Test("Without search terms every crash is listed, with no matched frame")
    func noTerms() throws {
        let result = try #require(searchable.result(for: []))

        #expect(result.id == searchable.id)
        #expect(result.matchedFrame == nil)
    }

    @Test("A term in the crash name matches without pointing at a frame")
    func nameMatch() throws {
        let result = try #require(searchable.result(for: ["nsrangeexception"]))

        #expect(result.matchedFrame == nil)
    }

    @Test("A term in the formatted date matches")
    func dateMatch() throws {
        let year = String(Calendar.current.component(.year, from: searchable.crash.details.date))

        let result = try #require(searchable.result(for: [year]))

        #expect(result.matchedFrame == nil)
    }

    @Test("A term only in a frame's symbol shows that symbol")
    func symbolMatch() throws {
        let result = try #require(searchable.result(for: ["feeddatasource"]))

        #expect(result.matchedFrame == "$s11Example_iOS14FeedDataSourceC4itemyyF")
    }

    @Test("A term in a frame's image shows the image before the symbol")
    func imageMatch() throws {
        let result = try #require(searchable.result(for: ["corefoundation"]))

        #expect(result.matchedFrame == "CoreFoundation __exceptionPreprocess")
    }

    @Test("Every term has to be found, in the row or in a frame")
    func allTermsRequired() {
        #expect(searchable.result(for: ["beyond", "exceptionpreprocess"]) != nil)
        #expect(searchable.result(for: ["beyond", "missing"]) == nil)
    }

    @Test("A number doesn't match the lengths inside a mangled symbol")
    func numbersIgnoreSymbols() {
        // "9876" is only in the mangled `$s9876Widget` length prefix; "7" is in the crash name.
        #expect(searchable.result(for: ["9876"]) == nil)
        #expect(searchable.result(for: ["7"]) != nil)
    }

    @Test("A number matches inside a symbol that isn't mangled")
    func numbersMatchUnmangledSymbols() throws {
        let result = try #require(searchable.result(for: ["256"]))

        #expect(result.matchedFrame == "CC_SHA256")
    }

    @Test("A term that matches nothing hides the crash")
    func noMatch() {
        #expect(searchable.result(for: ["sigsegv"]) == nil)
    }

    @Test("A crash keeps its id when a newer crash is added before it")
    func idSurvivesNewCrash() {
        let older = makeCrash(name: "older", date: Date(timeIntervalSince1970: 1_000))
        let newer = makeCrash(name: "newer", date: Date(timeIntervalSince1970: 2_000))

        let before = CrashModel.Searchable.list(from: [older])
        let after = CrashModel.Searchable.list(from: [newer, older])

        #expect(after.first { $0.crash.details.name == "older" }?.id == before.first?.id)
    }

    @Test("Crashes with the same date and name still get an id each")
    func duplicatesGetDistinctIds() {
        let crash = makeCrash(name: "same", date: Date(timeIntervalSince1970: 1_000))

        let ids = CrashModel.Searchable.list(from: [crash, crash]).map(\.id)

        #expect(Set(ids).count == 2)
    }

    private func makeCrash(name: String, date: Date) -> CrashModel {
        CrashModel(
            type: .signal,
            details: CrashModel.Details(name: name, date: date, deviceInfo: DeviceTool.Info()),
            traces: []
        )
    }
}
