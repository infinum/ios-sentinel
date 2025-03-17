//
//  Sentinel.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

/// Defines singleton instance of the Sentinel.
///
/// The Sentinel can be configured with different configurations. Based on
/// the provided configuration, Sentinel will be triggered from different events and show different tools.
public final class Sentinel {

    // MARK: - Internal properties
    
    var configuration: Configuration?

    // MARK: - Public properties
    
    /// Singleton instance of the Sentinel.
    public static let shared = Sentinel()
    
    // MARK: - Public methods
    
    /// Setups the Sentinel with provided configuration.
    ///
    /// - Parameter configuration: The configuration used to setup current instance of the Sentinel.
    public func setup(with configuration: Configuration) {
        self.configuration = configuration
        configuration.trigger?.subscribe {
            guard configuration.sourceScreenProvider.shouldShowSentinel() else {
                configuration.sourceScreenProvider.dismissSentinel()
                return
            }
            configuration.sourceScreenProvider.showTools(for: Self.createSentinelView(with: configuration))
        }
    }

    /// Creates the Sentinel View with tools.
    ///
    /// - Parameter configuration: The configuration used to setup current instance of the Sentinel.
    public static func createSentinelView(with configuration: Configuration) -> SentinelTabBarView {
        let tabItems = createTabItems(
            with: configuration.tools,
            preferences: configuration.preferences
        )

        return SentinelTabBarView(tabs: tabItems)
    }
}

// MARK: - Configuration

public extension Sentinel {

    /// Defines configuration used to define Sentinel.
    ///
    /// Based on the provided properties, Sentinel will be shown based on different event
    /// and it will show different tools.
    struct Configuration {

        // MARK: - Public properties

        /// The trigger event which starts the Sentinel.
        public let trigger: Trigger?

        /// The screen used for presenting the Sentinel.
        public let sourceScreenProvider: SourceScreenProvider

        /// Tools which are available from the Sentinel.
        public let tools: [Tool]

        /// Items which are shown on preferences screen
        public let preferences: [PreferencesTool.Section]

        // MARK: - Lifecycle

        /// Creates a new configuration.
        ///
        /// - Parameters:
        ///     - trigger: The trigger event which opens the Sentinel.
        ///     - sourceScreenProvider: The screen from which Sentinel can be presented.
        ///     - tools: Tools available from the Sentinel.
        ///     - preferences: Section items which can allow or deny an activity inside the app
        public init(
            trigger: Trigger? = nil,
            sourceScreenProvider: SourceScreenProvider = SourceScreenProviders.default,
            tools: [Tool],
            preferences: [PreferencesTool.Section] = []
        ) {
            self.trigger = trigger
            self.sourceScreenProvider = sourceScreenProvider
            self.tools = tools
            self.preferences = preferences
        }
    }
}
