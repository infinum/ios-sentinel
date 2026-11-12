//
//  PulseToolTests.swift
//  SentinelPulseTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

#if os(iOS)
import Testing
@testable import SentinelPulse

@Suite("Pulse tool")
struct PulseToolTests {

    @Test("Uses Pulse as the default name")
    func defaultName() {
        #expect(PulseTool().name == "Pulse")
    }

    @Test("Keeps a custom name")
    func customName() {
        #expect(PulseTool(name: "Network logs").name == "Network logs")
    }

    @Test("Builds its console content")
    func content() {
        _ = PulseTool().content
    }
}
#endif
