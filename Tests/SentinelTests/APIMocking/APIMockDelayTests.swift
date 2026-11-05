//
//  APIMockDelayTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 05.11.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("API mock delay")
struct APIMockDelayTests {

    @Test(
        "The delay is kept between 0 and an hour",
        arguments: [
            (TimeInterval.infinity, TimeInterval(3600)),
            (TimeInterval.nan, 0),
            (-1, 0),
            (7200, 3600),
            (0.5, 0.5)
        ]
    )
    func delayIsClamped(delay: TimeInterval, expected: TimeInterval) {
        let mock = APIMock(
            name: "Slow",
            url: .wildcard("/slow"),
            body: .json(""),
            delay: delay
        )

        #expect(mock.delay == expected)
    }

    @Test("A delay set after the mock is made is clamped too")
    func assignedDelayIsClamped() {
        var mock = APIMock(
            name: "Slow",
            url: .wildcard("/slow"),
            error: .timedOut
        )

        mock.delay = .infinity

        #expect(mock.delay == 3600)
    }

    @Test("An infinite delay is shown as an hour")
    func infiniteDelayIsFormatted() {
        let mock = APIMock(
            name: "Slow",
            url: .wildcard("/slow"),
            body: .json(""),
            delay: .infinity
        )

        #expect(mock.delay.formattedSeconds == "3600s")
    }
}
