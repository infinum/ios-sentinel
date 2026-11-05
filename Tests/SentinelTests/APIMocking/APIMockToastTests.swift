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
}
