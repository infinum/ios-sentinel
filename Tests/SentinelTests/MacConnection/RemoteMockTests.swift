//
//  RemoteMockTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Remote mocks")
struct RemoteMockTests {

    private let directory: TemporaryDirectory

    init() throws {
        directory = try TemporaryDirectory()
    }

    @Test("An HTTP mock comes back unchanged")
    func httpRoundTrip() throws {
        let mock = APIMock(
            id: "products",
            name: "Products",
            description: "Two products",
            group: "Catalog",
            method: .post,
            url: .regex("/products/\\d+$"),
            statusCode: 201,
            headers: ["X-Test": "1"],
            body: .json(#"{ "id": 1 }"#),
            delay: 1.5
        )

        #expect(try RemoteMock(mock: mock, isLocal: true).makeAPIMock() == mock)
    }

    @Test("A network error mock for any method comes back unchanged")
    func networkErrorRoundTrip() throws {
        let mock = APIMock(name: "Offline", url: .wildcard("/products"), error: .timedOut)

        #expect(try RemoteMock(mock: mock, isLocal: false).makeAPIMock() == mock)
    }

    @Test("A file body travels as its text and file name")
    func fileBody() throws {
        let file = try directory.createFile(named: "products.json", contents: "[]")
        let mock = APIMock(name: "Products", url: .wildcard("/products"), body: .file(file))

        let remoteMock = RemoteMock(mock: mock, isLocal: false)

        #expect(remoteMock.response == .http(statusCode: 200, headers: [:], body: RemoteMock.Body(text: "[]", fileName: "products.json")))
        #expect(remoteMock.warning == nil)
        #expect(try remoteMock.makeAPIMock().response == .http(statusCode: 200, headers: [:], body: .json("[]")))
    }

    @Test("A missing body file comes with the device's warning")
    func missingFile() {
        let mock = APIMock(
            name: "Products",
            url: .wildcard("/products"),
            body: .file(directory.url.appendingPathComponent("missing.json"))
        )

        #expect(RemoteMock(mock: mock, isLocal: false).warning == "Missing body file missing.json.")
    }

    @Test("A method this version doesn't know is refused rather than read as any method")
    func unknownMethod() {
        var remoteMock = RemoteMock(mock: APIMock(name: "Products", url: .wildcard("/products"), body: .json("")), isLocal: true)
        remoteMock.method = "PROPFIND"

        #expect(throws: RemoteMockError.unknownMethod("PROPFIND")) {
            try remoteMock.makeAPIMock()
        }
    }

    @Test("The list puts local mocks first and marks them")
    func list() {
        let app = APIMock(name: "App", url: .wildcard("/app"), body: .json(""))
        let local = APIMock(name: "Local", url: .wildcard("/local"), body: .json(""))

        let list = RemoteMock.list(appMocks: [app], localMocks: [local])

        #expect(list.map(\.name) == ["Local", "App"])
        #expect(list.map(\.isLocal) == [true, false])
    }

    @Test("Messages survive encoding")
    func messageCoding() throws {
        let message = RemoteMessage.mockCommand(
            RemoteMockCommand.save(
                RemoteMock(mock: APIMock(name: "Products", url: .wildcard("/products"), body: .json("{}")), isLocal: true)
            )
        )

        let decoded = try JSONDecoder().decode(RemoteMessage.self, from: JSONEncoder().encode(message))

        #expect(decoded == message)
    }
}
