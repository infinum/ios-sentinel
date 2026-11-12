//
//  JSONFormatterTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("JSON formatter")
struct JSONFormatterTests {

    @Test("Pretty printing keeps key order and numbers as written")
    func keepsOrderAndNumbers() {
        let json = #"{"zeta":1234.10,"alpha":[1,2],"nested":{"b":true,"a":null}}"#

        #expect(JSONFormatter.prettyPrinted(json) == """
        {
          "zeta": 1234.10,
          "alpha": [
            1,
            2
          ],
          "nested": {
            "b": true,
            "a": null
          }
        }
        """)
    }

    @Test("Strings are copied as they are, including brackets, commas and escaped quotes")
    func strings() {
        let json = #"{"text":"a, {b}: [c] \"d\" \\"}"#

        #expect(JSONFormatter.prettyPrinted(json) == """
        {
          "text": "a, {b}: [c] \\"d\\" \\\\"
        }
        """)
    }

    @Test("Empty containers stay on one line")
    func emptyContainers() {
        #expect(JSONFormatter.prettyPrinted(#"{ "a": {}, "b": [ ] }"#) == """
        {
          "a": {},
          "b": []
        }
        """)
    }

    @Test("Formatting already formatted JSON changes nothing")
    func idempotent() throws {
        let formatted = try #require(JSONFormatter.prettyPrinted(#"{"a":[{"b":1}]}"#))

        #expect(JSONFormatter.prettyPrinted(formatted) == formatted)
    }

    @Test("Invalid JSON isn't formatted")
    func invalid() {
        #expect(JSONFormatter.prettyPrinted(#"{"a":}"#) == nil)
        #expect(!JSONFormatter.isValid("{"))
        #expect(JSONFormatter.isValid("42"))
    }

    @Test("Typographic quotes are straightened only when that makes the JSON valid")
    func repairingQuotes() {
        #expect(JSONFormatter.repairingQuotes(in: "{ “a”: ‘b’ }") == "{ “a”: ‘b’ }")
        #expect(JSONFormatter.repairingQuotes(in: "{ “a”: “b” }") == #"{ "a": "b" }"#)
        #expect(JSONFormatter.repairingQuotes(in: #"{ "quote": "„Dobar dan“" }"#) == #"{ "quote": "„Dobar dan“" }"#)
    }
}
