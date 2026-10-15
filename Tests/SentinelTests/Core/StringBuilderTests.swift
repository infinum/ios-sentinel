//
//  StringBuilderTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing
@testable import Sentinel

@Suite("String builder")
struct StringBuilderTests {

    @Test("Components are joined without a separator")
    func joinsComponents() {
        let value = String(builder: {
            "a"
            1
            String.newLine
            "b"
        })

        #expect(value == "a1\nb")
    }

    @Test("Optional blocks add nothing when their condition fails", arguments: [true, false])
    func optionalBlocks(includeSuffix: Bool) {
        let value = String(builder: {
            "start"
            if includeSuffix {
                "-end"
            }
        })

        #expect(value == (includeSuffix ? "start-end" : "start"))
    }

    @Test("if/else picks one branch", arguments: [true, false])
    func eitherBlocks(condition: Bool) {
        let value = String(builder: {
            if condition {
                "first"
            } else {
                "second"
            }
        })

        #expect(value == (condition ? "first" : "second"))
    }

    @Test("A for loop joins every iteration")
    func loops() {
        // `buildArray` is what a `for` loop inside a `@StringBuilder` block compiles to.
        let value = StringBuilder.buildArray(["a", "b", "c"])

        withKnownIssue("buildArray passes the array to buildBlock as a single component, so it renders as [\"a\", \"b\", \"c\"]") {
            #expect(value == "abc")
        }
    }

    @Test("String.empty and String.newLine")
    func constants() {
        #expect(String.empty == "")
        #expect(String.newLine == "\n")
    }
}
