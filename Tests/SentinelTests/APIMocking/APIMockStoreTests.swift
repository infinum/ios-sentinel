//
//  APIMockStoreTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("API mock store")
struct APIMockStoreTests {

    private let directory: TemporaryDirectory
    private let matcher = APIMockMatcher()

    init() throws {
        directory = try TemporaryDirectory()
    }

    @Test("Mocks start switched off, with mocking itself on")
    func defaults() {
        let store = makeStore()
        store.setAppMocks([mock("Products")])

        #expect(store.isMockingEnabled)
        #expect(store.enabledIDs.isEmpty)
        #expect(store.activeMocks.isEmpty)
    }

    @Test("Switching a mock on makes it answer requests")
    func switchOn() {
        let store = makeStore()
        let products = mock("Products")
        store.setAppMocks([products])

        store.setEnabled(true, for: products)

        #expect(store.activeMocks == [products])
        #expect(matcher.mock(for: request("https://example.com/products")) == products)
    }

    @Test("Switching a mock on switches off the others for the same endpoint")
    func oneMockPerEndpoint() {
        let store = makeStore()
        let empty = mock("Empty")
        let error = mock("Error", statusCode: 500)
        let other = mock("Other", pattern: "/other")
        store.setAppMocks([empty, error, other])
        store.setEnabled(true, for: empty)
        store.setEnabled(true, for: other)

        store.setEnabled(true, for: error)

        #expect(store.enabledIDs == [error.id, other.id])
    }

    @Test("The master switch stops every mock without forgetting which are on")
    func masterSwitch() {
        let store = makeStore()
        let products = mock("Products")
        store.setAppMocks([products])
        store.setEnabled(true, for: products)

        store.setMockingEnabled(false)

        #expect(store.activeMocks.isEmpty)
        #expect(matcher.mock(for: request("https://example.com/products")) == nil)
        #expect(store.isEnabled(products))

        store.setMockingEnabled(true)

        #expect(store.activeMocks == [products])
    }

    @Test("Local mocks are tried before app mocks")
    func localMocksFirst() {
        let store = makeStore()
        let app = mock("App", pattern: "/products*")
        let local = mock("Local", id: "local.1")
        store.setAppMocks([app])
        store.save(local)
        store.setEnabled(true, for: app)
        store.setEnabled(true, for: local)

        #expect(store.activeMocks == [local, app])
        #expect(matcher.mock(for: request("https://example.com/products")) == local)
    }

    @Test("Saving an enabled local mock onto another mock's endpoint switches that one off")
    func editingMovesEndpoint() {
        let store = makeStore()
        let app = mock("App")
        var local = mock("Local", id: "local.1", pattern: "/elsewhere")
        store.setAppMocks([app])
        store.save(local)
        store.setEnabled(true, for: app)
        store.setEnabled(true, for: local)

        local.url = .wildcard("/products")
        store.save(local)

        #expect(store.enabledIDs == [local.id])
        #expect(store.localMocks == [local])
    }

    @Test("Deleting a local mock forgets its switch")
    func delete() {
        let store = makeStore()
        let local = mock("Local", id: "local.1")
        store.save(local)
        store.setEnabled(true, for: local)

        store.delete(local)

        #expect(store.localMocks.isEmpty)
        #expect(store.enabledIDs.isEmpty)
    }

    @Test("A second app mock with the same id is ignored")
    func duplicateIDs() {
        let store = makeStore()
        let first = mock("Products")
        let second = mock("Products", pattern: "/other")

        store.setAppMocks([first, second])

        #expect(store.appMocks == [first])
    }

    @Test("Local mocks and switches are saved and loaded")
    func persistence() {
        let store = makeStore()
        let app = mock("App")
        let local = APIMock(
            id: "local.1",
            name: "Local",
            description: "Saved",
            group: "Orders",
            method: .post,
            url: .regex("/orders$"),
            statusCode: 201,
            headers: ["X-Custom": "1"],
            body: .json(#"{ "id": 1 }"#),
            delay: 2
        )
        let offline = APIMock(
            id: "local.2",
            name: "Offline",
            url: .wildcard("/orders"),
            error: .timedOut
        )
        store.setAppMocks([app])
        store.save(local)
        store.save(offline)
        store.setEnabled(true, for: app)
        store.setMockingEnabled(false)

        let reloaded = makeStore()
        reloaded.setAppMocks([app])

        #expect(reloaded.localMocks == [local, offline])
        #expect(reloaded.enabledIDs == [app.id])
        #expect(!reloaded.isMockingEnabled)
    }

    @Test("A file that can't be read is moved aside instead of being overwritten")
    func corruptFile() throws {
        try directory.createFile(named: "APIMocking.json", contents: "not json")

        let store = makeStore()

        #expect(store.localMocks.isEmpty)
        #expect(FileManager.default.fileExists(atPath: directory.url.appendingPathComponent("APIMocking.corrupt.json").path))
    }

    @Test("Fields missing from the file fall back to defaults")
    func partialFile() throws {
        try directory.createFile(
            named: "APIMocking.json",
            contents: #"{ "localMocks": [{ "id": "local.1", "name": "Minimal", "pattern": "/a" }, { "name": "No id" }] }"#
        )

        let store = makeStore()

        #expect(store.isMockingEnabled)
        #expect(store.localMocks.map(\.id) == ["local.1"])
        #expect(store.localMocks.first?.response == .http(statusCode: 200, headers: [:], body: .json("")))
    }
}

// MARK: - Helpers

private extension APIMockStoreTests {

    func makeStore() -> APIMockStore {
        APIMockStore(
            persistence: APIMockPersistence(fileURL: directory.url.appendingPathComponent("APIMocking.json")),
            matcher: matcher
        )
    }

    func mock(
        _ name: String,
        id: String? = nil,
        pattern: String = "/products",
        statusCode: Int = 200
    ) -> APIMock {
        APIMock(
            id: id,
            name: name,
            url: .wildcard(pattern),
            statusCode: statusCode,
            body: .json("{}")
        )
    }

    func request(_ url: String) -> URLRequest {
        URLRequest(url: URL(string: url)!)
    }
}
