//
//  APIMockToastTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 05.11.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("API mock toasts")
struct APIMockToastTests {

    @Test("The launch toast names the mock when only one is on")
    func launchWithOneMock() {
        let message = APIMockToastMessage.launch(activeMocks: [mock("Repository")])

        #expect(message == APIMockToastMessage(title: "API mocking is on", subtitle: "“Repository” answers requests"))
    }

    @Test("The launch toast counts the mocks when several are on")
    func launchWithSeveralMocks() {
        let message = APIMockToastMessage.launch(activeMocks: [mock("Products"), mock("Orders")])

        #expect(message.subtitle == "2 mocks answer requests")
    }

    @Test("The request toast names the mock, the request and the answer")
    func request() {
        let message = APIMockToastMessage.request(request("https://example.com/repository?page=2"), mockedBy: mock("Repository"))

        #expect(message == APIMockToastMessage(title: "Mocked by “Repository”", subtitle: "GET /repository · 200"))
    }

    @Test("The request toast says which network error the mock failed with")
    func requestWithNetworkError() {
        let offline = APIMock(
            name: "Offline",
            method: .get,
            url: .wildcard("/repository"),
            error: .notConnectedToInternet
        )

        let message = APIMockToastMessage.request(request("https://example.com/repository"), mockedBy: offline)

        #expect(message.subtitle == "GET /repository · No internet connection")
    }

    @Test("A mock for any method shows the request's method")
    func requestMethodFromTheRequest() {
        var post = request("https://example.com/repository")
        post.httpMethod = "POST"

        let message = APIMockToastMessage.request(post, mockedBy: mock("Repository", method: nil))

        #expect(message.subtitle == "POST /repository · 200")
    }

    @Test("Requests answered by one mock while the toast is up are counted")
    func burstFromOneMock() {
        var burst = APIMockRequestBurst()
        let repository = mock("Repository")

        _ = burst.add(request("https://example.com/repository"), mockedBy: repository)
        _ = burst.add(request("https://example.com/repository"), mockedBy: repository)
        let message = burst.add(request("https://example.com/repository"), mockedBy: repository)

        #expect(message == APIMockToastMessage(title: "Mocked by “Repository”", subtitle: "Answered 3 requests"))
    }

    @Test("Requests answered by different mocks while the toast is up are counted with the mocks")
    func burstFromSeveralMocks() {
        var burst = APIMockRequestBurst()

        _ = burst.add(request("https://example.com/products"), mockedBy: mock("Products"))
        _ = burst.add(request("https://example.com/orders"), mockedBy: mock("Orders"))
        let message = burst.add(request("https://example.com/products"), mockedBy: mock("Products"))

        #expect(message == APIMockToastMessage(title: "3 requests mocked", subtitle: "By 2 mocks"))
    }
}

private extension APIMockToastTests {

    func mock(
        _ name: String,
        method: APIMock.HTTPMethod? = .get
    ) -> APIMock {
        APIMock(
            name: name,
            method: method,
            url: .wildcard("/\(name.lowercased())"),
            body: .json("{}")
        )
    }

    func request(_ url: String) -> URLRequest {
        URLRequest(url: URL(string: url)!)
    }
}
