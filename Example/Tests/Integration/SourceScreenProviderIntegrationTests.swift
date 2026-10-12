//
//  SourceScreenProviderIntegrationTests.swift
//  Sentinel_Tests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing
import UIKit
@testable import Sentinel

extension IntegrationTests {

    @Suite("Default source screen provider")
    @MainActor
    struct SourceScreenProviderIntegrationTests {

        private let provider = DefaultSourceScreenProvider()

        @Test("Nothing is shown before Sentinel is presented")
        func notShownInitially() {
            #expect(!provider.isShown())
        }

        @Test("Sentinel is presented on top of the app and dismissed again")
        func presentAndDismiss() async throws {
            let view = Sentinel.createSentinelView(with: Sentinel.Configuration(tools: []))

            provider.showTools(for: view)
            try await waitUntil { provider.isShown() }

            provider.dismiss()
            try await waitUntil { !provider.isShown() && !isPresenting() }
        }

        private func isPresenting() -> Bool {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .contains { $0.rootViewController?.presentedViewController != nil }
        }

        /// Polls for up to five seconds, because presentation and dismissal are animated.
        private func waitUntil(_ condition: () -> Bool) async throws {
            for _ in 0..<50 where !condition() {
                try await Task.sleep(nanoseconds: 100_000_000)
            }
            #expect(condition())
        }
    }
}
