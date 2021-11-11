//
//  Sentinel.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

/// Defines singleton instance of the Sentinel.
///
/// The Sentinel can be configured with different configurations and based on
/// the configuration used will be triggered from different events and show different tools.
@objcMembers
public class Sentinel: NSObject {
    
    // MARK: - Private properties
    
    internal var configuration: Configuration?

    // MARK: - Public properties
    
    /// Singleton instance of the Sentinel.
    @objc(sharedInstance)
    public static let shared = Sentinel()
    
    // MARK: - Lifecycle
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public methods
    
    /// Setups the Sentinel with provided configuration.
    ///
    /// - Parameter configuration: The configuration used to setup current instance of the Sentinel.
    @objc(setupWithConfiguration:)
    public func setup(with configuration: Configuration) {
        self.configuration = configuration
        configuration.trigger.subscribe { [weak self] in
            guard let viewController = configuration.sourceScreenProvider.viewControllerForShowingTools else { return }
            self?.present(tools: configuration.tools, optionSwitchItems: configuration.optionSwitchItems, on: viewController)
        }
    }
    
    // MARK: - Inner classes
    
    /// Defines configuration used to define Sentinel.
    ///
    /// Based on the provided properties, Sentinel will be shown based on different event
    /// and it will show different tools.
    @objcMembers
    public class Configuration: NSObject {
        
        // MARK: - Public properties
        
        /// The trigger event which starts the Sentinel.
        public let trigger: Trigger
        
        /// The screen used for presenting the Sentinel.
        public let sourceScreenProvider: SourceScreenProvider
        
        /// Tools which are available from the Sentinel.
        public let tools: [Tool]

        /// Items which are shown on preferences screen
        public let optionSwitchItems: [OptionSwitchItem]
        // MARK: - Lifecycle

        /// Creates a new configuration.
        ///
        /// - Parameters:
        ///     - trigger: The trigger event which opens the Sentinel.
        ///     - sourceScreenProvider: The screen from which Sentinel can be presented.
        ///     - tools: Tools available from the Sentinel.
        public init(
            trigger: Trigger,
            sourceScreenProvider: SourceScreenProvider = SourceScreenProviders.default,
            tools: [Tool],
            optionSwitchItems: [OptionSwitchItem] = []
        ) {
            self.trigger = trigger
            self.sourceScreenProvider = sourceScreenProvider
            self.tools = tools
            self.optionSwitchItems = optionSwitchItems
            super.init()
        }
    }
}
