//
//  URLPatternTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("API mock URL patterns")
struct URLPatternTests {

    @Test(
        "A wildcard matches URLs ending with the path, whatever the host, query or trailing slash",
        arguments: [
            "https://example.com/api/v2/products",
            "https://example.com/api/v2/products/",
            "https://example.com/api/v2/products?page=2",
            "http://staging.example.com:8080/api/v2/products",
            "https://example.com/API/V2/Products"
        ]
    )
    func wildcardMatchesPath(url: String) {
        #expect(APIMock.URLPattern.wildcard("/api/v2/products").matches(url))
    }

    @Test(
        "A wildcard doesn't match longer paths or similarly named endpoints",
        arguments: [
            "https://example.com/api/v2/products/42",
            "https://example.com/api/v2/products-legacy",
            "https://example.com/api/v2/product"
        ]
    )
    func wildcardDoesNotMatchOtherPaths(url: String) {
        #expect(!APIMock.URLPattern.wildcard("/api/v2/products").matches(url))
    }

    @Test("A missing leading slash still matches")
    func wildcardWithoutLeadingSlash() {
        #expect(APIMock.URLPattern.wildcard("api/v2/products").matches("https://example.com/api/v2/products"))
    }

    @Test("* matches any run of characters")
    func wildcardStar() {
        let pattern = APIMock.URLPattern.wildcard("/accounts/*/details")

        #expect(pattern.matches("https://example.com/accounts/HR123/details"))
        #expect(pattern.matches("https://example.com/accounts/1/2/details"))
        #expect(!pattern.matches("https://example.com/accounts/HR123/transactions"))
        #expect(APIMock.URLPattern.wildcard("/api/v2/products*").matches("https://example.com/api/v2/products/42/reviews"))
    }

    @Test("With a ? in it, a wildcard matches the query too")
    func wildcardWithQuery() {
        let pattern = APIMock.URLPattern.wildcard("/api/v1/parameters?name=identyum.available")

        #expect(pattern.matches("https://example.com/api/v1/parameters?name=identyum.available"))
        #expect(!pattern.matches("https://example.com/api/v1/parameters?name=pricing"))
        #expect(!pattern.matches("https://example.com/api/v1/parameters"))
    }

    @Test("Regex characters in a wildcard are taken literally")
    func wildcardEscapesRegexCharacters() {
        let pattern = APIMock.URLPattern.wildcard("/v1.0/items(all)")

        #expect(pattern.matches("https://example.com/v1.0/items(all)"))
        #expect(!pattern.matches("https://example.com/v1x0/items(all)"))
    }

    @Test("A regex matches anywhere in the full URL, ignoring case")
    func regex() {
        let pattern = APIMock.URLPattern.regex(#"/users/\d+$"#)

        #expect(pattern.matches("https://example.com/api/USERS/42"))
        #expect(!pattern.matches("https://example.com/api/users/42/avatar"))
        #expect(APIMock.URLPattern.regex("example\\.com").matches("https://example.com/anything"))
    }

    @Test("Empty patterns and invalid regexes match nothing and explain why")
    func unusablePatterns() {
        let empty = APIMock.URLPattern.wildcard("  ")
        let invalid = APIMock.URLPattern.regex("(unclosed")

        #expect(!empty.matches("https://example.com/"))
        #expect(!invalid.matches("https://example.com/(unclosed"))
        #expect(empty.validationError != nil)
        #expect(invalid.validationError != nil)
        #expect(APIMock.URLPattern.wildcard("/a").validationError == nil)
    }

    @Test("Mocks share an endpoint when the pattern is the same and the methods overlap")
    func sharesEndpoint() {
        let get = mock(id: "a", method: .get, url: .wildcard("/products"))

        #expect(get.sharesEndpoint(with: mock(id: "b", method: .get, url: .wildcard(" /PRODUCTS "))))
        #expect(get.sharesEndpoint(with: mock(id: "b", method: nil, url: .wildcard("/products"))))
        #expect(!get.sharesEndpoint(with: mock(id: "b", method: .post, url: .wildcard("/products"))))
        #expect(!get.sharesEndpoint(with: mock(id: "b", method: .get, url: .regex("/products"))))
        #expect(!get.sharesEndpoint(with: mock(id: "b", method: .get, url: .wildcard("/products/*"))))
        #expect(!get.sharesEndpoint(with: get))
    }

    @Test("The summaries name the method and pattern, and the response and delay")
    func summary() {
        let http = APIMock(
            name: "Products",
            method: .get,
            url: .wildcard("/api/v2/products"),
            statusCode: 503,
            body: .json("{}"),
            delay: 1.5
        )
        let error = APIMock(
            name: "Offline",
            url: .regex("/products$"),
            error: .notConnectedToInternet
        )

        #expect(http.requestSummary == "GET /api/v2/products")
        #expect(http.responseSummary == "503 · 1.5s delay")
        #expect(error.requestSummary == "ANY regex /products$")
        #expect(error.responseSummary == "No internet connection")
    }

    @Test("A body file that doesn't exist is reported")
    func missingFileWarning() {
        let mock = APIMock(
            name: "Missing",
            url: .wildcard("/a"),
            body: .file(named: "does-not-exist", in: .main)
        )

        #expect(mock.warning == "Missing body file does-not-exist.json.")
    }
}

// MARK: - Helpers

private extension URLPatternTests {

    func mock(id: String, method: APIMock.HTTPMethod?, url: APIMock.URLPattern) -> APIMock {
        APIMock(
            id: id,
            name: id,
            method: method,
            url: url,
            body: .json("{}")
        )
    }
}
