//
//  APIMockMatcherTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("API mock matcher")
struct APIMockMatcherTests {

    private let matcher = APIMockMatcher()

    @Test("Nothing matches before mocks are set")
    func empty() {
        #expect(matcher.mock(for: request("https://example.com/products")) == nil)
    }

    @Test("The method has to match, and a request without one is a GET")
    func method() {
        let get = mock("get", method: .get)
        matcher.update(activeMocks: [get])

        #expect(matcher.mock(for: request("https://example.com/products")) == get)
        #expect(matcher.mock(for: request("https://example.com/products", method: "get")) == get)
        #expect(matcher.mock(for: request("https://example.com/products", method: "POST")) == nil)
    }

    @Test("A mock without a method answers any method")
    func anyMethod() {
        let any = mock("any", method: nil)
        matcher.update(activeMocks: [any])

        #expect(matcher.mock(for: request("https://example.com/products", method: "DELETE")) == any)
    }

    @Test("The first matching mock wins")
    func order() {
        let first = mock("first", method: nil)
        let second = mock("second", method: nil)
        matcher.update(activeMocks: [first, second])

        #expect(matcher.mock(for: request("https://example.com/products")) == first)
    }

    @Test("Only http and https requests are matched")
    func scheme() {
        matcher.update(activeMocks: [APIMock(name: "all", url: .wildcard("*"), body: .json("{}"))])

        #expect(matcher.mock(for: request("https://example.com/products")) != nil)
        #expect(matcher.mock(for: request("wss://example.com/products")) == nil)
        #expect(matcher.mock(for: request("file:///tmp/products")) == nil)
    }

    @Test("Mocks with unusable patterns are skipped")
    func unusablePattern() {
        let invalid = APIMock(name: "invalid", url: .regex("("), body: .json("{}"))
        let valid = mock("valid", method: nil)
        matcher.update(activeMocks: [invalid, valid])

        #expect(matcher.mock(for: request("https://example.com/products")) == valid)
    }
}

// MARK: - Helpers

private extension APIMockMatcherTests {

    func mock(_ name: String, method: APIMock.HTTPMethod?) -> APIMock {
        APIMock(
            name: name,
            method: method,
            url: .wildcard("/products"),
            body: .json("{}")
        )
    }

    func request(_ url: String, method: String? = nil) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        return request
    }
}
