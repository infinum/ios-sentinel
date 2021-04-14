//
//  ToolBox.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

/// Defines singleton instance of the toolbox.
///
/// The toolbox can be configured with different configurations and based on
/// the configuration used will be triggered from different events and show different tools.
@objcMembers
public class ToolBox: NSObject {
    
    // MARK: - Private properties
    
    internal var configuration: Configuration?

    // MARK: - Public properties
    
    /// Singleton instance of the toolbox.
    @objc(sharedInstance)
    public static let shared = ToolBox()
    
    // MARK: - Lifecycle
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public methods
    
    /// Setups the toolbox with provided configuration.
    ///
    /// - Parameter configuration: The configuration used to setup current instance of the toolbox.
    @objc(setupWithConfiguration:)
    public func setup(with configuration: Configuration) {
        self.configuration = configuration
        configuration.trigger.subscribe { [weak self] in
            guard let viewController = configuration.sourceScreenProvider.viewControllerForShowingTools else { return }
            self?.present(tools: configuration.tools, on: viewController)
        }
    }
    
    // MARK: - Inner classes
    
    /// Defines configuration used to define toolbox.
    ///
    /// Based on the provided properties, toolbox will be shown based on different event
    /// and it will show different tools.
    @objcMembers
    public class Configuration: NSObject {
        
        // MARK: - Public properties
        
        /// The trigger event which starts the toolbox.
        public let trigger: Trigger
        
        /// The screen used for presenting the toolbox.
        public let sourceScreenProvider: SourceScreenProvider
        
        /// Tools which are available from the toolbox.
        public let tools: [Tool]
        
        // MARK: - Lifecycle

        /// Creates a new configuration.
        ///
        /// - Parameters:
        ///     - trigger: The trigger event which opens the toolbox.
        ///     - sourceScreenProvider: The screen from which toolbox can be presented.
        ///     - tools: Tools available from the toolbox.
        public init(
            trigger: Trigger,
            sourceScreenProvider: SourceScreenProvider = SourceScreenProviders.default,
            tools: [Tool]
        ) {
            self.trigger = trigger
            self.sourceScreenProvider = sourceScreenProvider
            self.tools = tools
            super.init()
        }
    }
}
