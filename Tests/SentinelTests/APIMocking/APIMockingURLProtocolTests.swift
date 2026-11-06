//
//  APIMockingURLProtocolTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

// The protocol reads the shared matcher, so these tests take turns.
@Suite("API mocking URL protocol", .serialized)
struct APIMockingURLProtocolTests {

    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        APIMockingTool.register(in: configuration)
        session = URLSession(configuration: configuration)
    }

    @Test("A mocked request gets the mock's status, headers and body")
    func httpResponse() async throws {
        let mock = APIMock(
            name: "Products",
            url: .wildcard("/products"),
            statusCode: 503,
            headers: ["content-type": "text/plain", "X-Custom": "1"],
            body: .json(#"{ "error": "unavailable" }"#)
        )
        activate([mock])
        defer { activate([]) }

        let (data, response) = try await session.data(from: URL(string: "https://example.com/products?page=1")!)
        let httpResponse = try #require(response as? HTTPURLResponse)

        #expect(httpResponse.statusCode == 503)
        #expect(String(decoding: data, as: UTF8.self) == #"{ "error": "unavailable" }"#)
        #expect(httpResponse.value(forHTTPHeaderField: "Content-Type") == "text/plain")
        #expect(httpResponse.value(forHTTPHeaderField: "X-Custom") == "1")
        #expect(httpResponse.value(forHTTPHeaderField: APIMockingURLProtocol.mockHeaderName) == "Products")
    }

    @Test("The finished task's current request carries the header Pulse marks mocked requests by")
    func pulseHeader() async throws {
        activate([APIMock(name: "Products", url: .wildcard("/products"), body: .json("{}"))])
        defer { activate([]) }

        let task = await withCheckedContinuation { continuation in
            var task: URLSessionDataTask?
            task = session.dataTask(with: URL(string: "https://example.com/products")!) { _, _, _ in
                continuation.resume(returning: task!)
            }
            task?.resume()
        }

        #expect(task.currentRequest?.value(forHTTPHeaderField: APIMockingURLProtocol.pulseMockedHeaderName) == "true")
    }

    @Test("A network error mock fails the request with that error")
    func networkError() async {
        activate([APIMock(name: "Offline", url: .wildcard("/products"), error: .notConnectedToInternet)])
        defer { activate([]) }

        let error = await #expect(throws: URLError.self) {
            try await session.data(from: URL(string: "https://example.com/products")!)
        }

        #expect(error?.code == .notConnectedToInternet)
        #expect(error?.localizedDescription == "The Internet connection appears to be offline.")
        #expect(error?.failingURL?.path == "/products")
    }

    @Test("The response waits for the mock's delay")
    func delay() async throws {
        activate([APIMock(name: "Slow", url: .wildcard("/products"), body: .json("{}"), delay: 0.5)])
        defer { activate([]) }

        let start = Date()
        _ = try await session.data(from: URL(string: "https://example.com/products")!)

        #expect(Date().timeIntervalSince(start) >= 0.45)
    }

    @Test("A body file that can't be read fails the request")
    func missingFile() async {
        activate([APIMock(name: "Missing", url: .wildcard("/products"), body: .file(URL(fileURLWithPath: "/nonexistent.json")))])
        defer { activate([]) }

        let error = await #expect(throws: URLError.self) {
            try await session.data(from: URL(string: "https://example.com/products")!)
        }

        #expect(error?.code == .resourceUnavailable)
    }

    @Test("Requests no mock matches are left to the network")
    func unmatched() {
        activate([APIMock(name: "Products", url: .wildcard("/products"), body: .json("{}"))])
        defer { activate([]) }

        #expect(APIMockingURLProtocol.canInit(with: URLRequest(url: URL(string: "https://example.com/products")!)))
        #expect(!APIMockingURLProtocol.canInit(with: URLRequest(url: URL(string: "https://example.com/orders")!)))
    }

    @Test("Registering twice adds the protocol once, in front")
    func registerIsIdempotent() {
        let configuration = URLSessionConfiguration.ephemeral

        APIMockingTool.register(in: configuration)
        APIMockingTool.register(in: configuration)

        let classes = configuration.protocolClasses ?? []
        #expect(classes.first == APIMockingURLProtocol.self)
        #expect(classes.filter { $0 == APIMockingURLProtocol.self }.count == 1)
    }

    @Test("After installing, new default and ephemeral configurations are mocked")
    func automaticInjection() {
        URLSessionConfiguration.installAPIMocking

        #expect(URLSessionConfiguration.default.protocolClasses?.first == APIMockingURLProtocol.self)
        #expect(URLSessionConfiguration.ephemeral.protocolClasses?.first == APIMockingURLProtocol.self)
    }
}

// MARK: - Helpers

private extension APIMockingURLProtocolTests {

    func activate(_ mocks: [APIMock]) {
        APIMockMatcher.shared.update(activeMocks: mocks)
    }
}
