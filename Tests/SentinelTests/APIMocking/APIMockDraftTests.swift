//
//  APIMockDraftTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("API mock draft")
struct APIMockDraftTests {

    @Test("A new draft gets a local id and can't be saved until it has a name and a pattern")
    func newDraft() {
        var draft = APIMockDraft()

        #expect(draft.id.hasPrefix("local."))
        #expect(!draft.canSave)

        draft.name = "Products"
        #expect(!draft.canSave)

        draft.pattern = "/products"
        #expect(draft.canSave)
    }

    @Test("An invalid regex or status code blocks saving")
    func validation() {
        var draft = APIMockDraft()
        draft.name = "Products"
        draft.pattern = "("
        draft.matchKind = .regex

        #expect(draft.patternError != nil)
        #expect(!draft.canSave)

        draft.matchKind = .wildcard
        draft.statusCode = "99"
        #expect(draft.statusCodeValue == nil)
        #expect(!draft.canSave)

        draft.responseKind = .networkError
        #expect(draft.canSave)
    }

    @Test("A draft round-trips a mock")
    func roundTrip() {
        let mock = APIMock(
            id: "local.1",
            name: "Products",
            description: "Empty list",
            group: "Catalog",
            method: .get,
            url: .regex("/products$"),
            statusCode: 404,
            headers: ["X-Custom": "1"],
            body: .json("[]"),
            delay: 1
        )

        #expect(APIMockDraft(mock: mock).makeMock() == mock)
    }

    @Test("A copy gets a new local id and name, and the body of a file mock inline")
    func copying() throws {
        let directory = try TemporaryDirectory()
        let file = try directory.createFile(named: "products.json", contents: #"{ "items": [] }"#)
        let mock = APIMock(
            name: "Products",
            url: .wildcard("/products"),
            body: .file(file)
        )

        let copy = APIMockDraft(copying: mock).makeMock()

        #expect(copy.id.hasPrefix("local."))
        #expect(copy.name == "Products copy")
        #expect(copy.response == .http(statusCode: 200, headers: [:], body: .json(#"{ "items": [] }"#)))
    }

    @Test("Typographic quotes are straightened when the body is saved")
    func quotesAreRepaired() {
        var draft = APIMockDraft()
        draft.name = "Quotes"
        draft.pattern = "/a"
        draft.body = "{ “name”: “Ana” }"

        #expect(draft.jsonStatus == .valid)
        #expect(draft.makeMock().response == .http(statusCode: 200, headers: [:], body: .json(#"{ "name": "Ana" }"#)))
    }

    @Test("The body preview is the first five lines")
    func bodyPreview() {
        var draft = APIMockDraft()
        draft.body = (1...8).map { "line \($0)" }.joined(separator: "\n")

        #expect(draft.bodyPreview == "line 1\nline 2\nline 3\nline 4\nline 5")
        #expect(draft.bodySummary.hasPrefix("8 lines · "))

        draft.body += "\n"
        #expect(draft.bodySummary.hasPrefix("8 lines · "))
    }

    @Test("The preview of a one-line body is cut short")
    func minifiedBodyPreview() {
        var draft = APIMockDraft()
        draft.body = "[" + Array(repeating: "1", count: 1_000).joined(separator: ",") + "]"

        #expect(draft.bodyPreview.count == APIMockDraft.bodyPreviewLineCount * 120)
        #expect(draft.bodySummary.hasPrefix("1 line · "))
    }

    @Test("A blank group is no group")
    func blankGroup() {
        var draft = APIMockDraft()
        draft.name = "Products"
        draft.pattern = "/products"
        draft.group = "  "

        #expect(draft.makeMock().group == nil)

        draft.group = " Catalog "
        #expect(draft.makeMock().group == "Catalog")
    }

    @Test("The file name is made of the name's words")
    func fileName() {
        var draft = APIMockDraft()
        draft.name = "Products – Empty / v2"
        #expect(draft.fileName == "products-empty-v2")

        draft.name = "–"
        #expect(draft.fileName == "mock")
    }

    @Test("The Swift snippet recreates the mock with its body in a file")
    func swiftSnippet() {
        var draft = APIMockDraft()
        draft.name = "Products \"empty\""
        draft.group = "Catalog"
        draft.method = .get
        draft.pattern = "/api/v2/products"
        draft.statusCode = "404"
        draft.delay = 1.5

        #expect(draft.swiftSnippet == """
        APIMock(
            name: "Products \\"empty\\"",
            group: "Catalog",
            method: .get,
            url: .wildcard("/api/v2/products"),
            statusCode: 404,
            body: .file(named: "products-empty"),
            delay: 1.5
        )
        """)
    }

    @Test("The Swift snippet of a network error mock names the error")
    func swiftSnippetForError() {
        var draft = APIMockDraft()
        draft.name = "Offline"
        draft.matchKind = .regex
        draft.pattern = #"/users/\d+"#
        draft.responseKind = .networkError
        draft.networkError = .timedOut

        #expect(draft.swiftSnippet == #"""
        APIMock(
            name: "Offline",
            url: .regex("/users/\\d+"),
            error: .timedOut
        )
        """#)
    }
}
