//
//  APIMockShareTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("API mock sharing")
struct APIMockShareTests {

    @Test("The file name is made of the name's words")
    func fileName() {
        var draft = APIMockDraft()
        draft.name = "Products – Empty / v2"
        #expect(APIMockShare(draft: draft).fileName == "products-empty-v2")

        draft.name = "–"
        #expect(APIMockShare(draft: draft).fileName == "mock")
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

        #expect(APIMockShare(draft: draft).swiftSnippet == """
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

        #expect(APIMockShare(draft: draft).swiftSnippet == #"""
        APIMock(
            name: "Offline",
            url: .regex("/users/\\d+"),
            error: .timedOut
        )
        """#)
    }

    @Test("Sharing an HTTP mock hands over the snippet and the formatted body file")
    func items() throws {
        var draft = APIMockDraft()
        draft.name = "Shared body"
        draft.pattern = "/a"
        draft.body = #"{"a":1}"#

        let items = APIMockShare(draft: draft).makeItems()
        let fileURL = try #require(items.last as? URL)

        #expect(items.first as? String == APIMockShare(draft: draft).swiftSnippet)
        #expect(fileURL.lastPathComponent == "shared-body.json")
        #expect(try String(contentsOf: fileURL, encoding: .utf8) == "{\n  \"a\": 1\n}")
    }

    @Test("Sharing a network error mock hands over only the snippet")
    func errorItems() {
        var draft = APIMockDraft()
        draft.name = "Offline"
        draft.pattern = "/a"
        draft.responseKind = .networkError

        #expect(APIMockShare(draft: draft).makeItems().count == 1)
    }
}
