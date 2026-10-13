//
//  APIMockingTool.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI

/// Tool which answers the app's network requests with mocked responses.
///
/// The app passes its own mocks, usually backed by JSON files in the bundle, and testers can create
/// more in the tool by pasting a response body, without rebuilding the app. Each mock has its own
/// switch; switching one on switches off the other mocks for the same endpoint. Local mocks and the
/// switches are saved, survive relaunches and `ClearAppDataTool`, and are kept until changed in the tool.
///
/// Mocks are served by a `URLProtocol`, beneath `URLSession`, so the app's networking code runs as it
/// would for a real response. Pulse marks mocked requests as mocked, and every mocked response carries
/// an `X-Sentinel-Mock` header with the id of the mock that answered.
///
/// - Note: By default the tool adds its protocol to every `URLSessionConfiguration.default` and
/// `.ephemeral` configuration created after the tool, and to `URLSession.shared`. A configuration
/// created earlier needs ``register(in:)`` before a session is made from it. Background sessions,
/// web views and media playback are never mocked.
public struct APIMockingTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Lifecycle

    /// - Parameters:
    ///     - name: Name of the tool
    ///     - mocks: Mocks the app ships with. Testers switch them on in the tool.
    ///     - injectsAutomatically: Whether to add mocking to every `default` and `ephemeral` session
    ///     configuration created from now on, and to `URLSession.shared`. Without it, every configuration
    ///     needs ``register(in:)``.
    public init(
        name: String = "API Mocking",
        mocks: [APIMock] = [],
        injectsAutomatically: Bool = true
    ) {
        self.name = name
        let store = APIMockStore.shared
        store.setAppMocks(mocks)
        if injectsAutomatically {
            URLSessionConfiguration.installAPIMocking
        }
        // Mocks stay on across launches, so say so where a developer will see it.
        let activeCount = store.activeMocks.count
        if activeCount > 0 {
            NSLog("Sentinel API mocking: %d mock(s) switched on.", activeCount)
        }
    }

    /// Adds mocking to a session configuration.
    ///
    /// Only needed for configurations created before the tool, or when automatic injection is off.
    /// Call it before creating the session, which copies its configuration.
    ///
    /// - Parameter configuration: The configuration a `URLSession` will be created with.
    public static func register(in configuration: URLSessionConfiguration) {
        configuration.addAPIMocking()
    }
}

// MARK: - UI

public extension APIMockingTool {

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View {
        APIMockingView(title: name, store: APIMockStore.shared)
    }
    #else
    var content: any View {
        APIMockingView(title: name, store: APIMockStore.shared)
    }
    #endif
}
