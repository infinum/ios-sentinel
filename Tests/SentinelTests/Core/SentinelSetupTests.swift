//
//  SentinelSetupTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing
@testable import Sentinel

@Suite("Sentinel setup")
struct SentinelSetupTests {

    // A fresh instance instead of `Sentinel.shared`, so tests don't share configuration.
    private let sentinel = Sentinel()
    private let trigger = MockTrigger()
    private let screenProvider = MockSourceScreenProvider()

    @Test("setup stores the configuration and subscribes to the trigger")
    func setupStoresConfiguration() {
        sentinel.setup(with: makeConfiguration())

        #expect(sentinel.configuration?.tools.map(\.name) == ["Tool"])
        #expect(trigger.events != nil)
    }

    @Test("Firing the trigger while hidden shows the tools")
    func triggerShowsToolsWhenHidden() {
        sentinel.setup(with: makeConfiguration())
        screenProvider.isShownResult = false

        trigger.fire()

        #expect(screenProvider.showToolsCount == 1)
        #expect(screenProvider.dismissCount == 0)
    }

    @Test("Firing the trigger while shown dismisses the tools")
    func triggerDismissesWhenShown() {
        sentinel.setup(with: makeConfiguration())
        screenProvider.isShownResult = true

        trigger.fire()

        #expect(screenProvider.showToolsCount == 0)
        #expect(screenProvider.dismissCount == 1)
    }

    @Test("Configuration defaults to no trigger and no preferences")
    func configurationDefaults() {
        let configuration = Sentinel.Configuration(tools: [])

        #expect(configuration.trigger == nil)
        #expect(configuration.preferences.isEmpty)
        #expect(configuration.tools.isEmpty)
    }
}

private extension SentinelSetupTests {

    func makeConfiguration() -> Sentinel.Configuration {
        Sentinel.Configuration(
            trigger: trigger,
            sourceScreenProvider: screenProvider,
            tools: [MockTool(name: "Tool")]
        )
    }
}
