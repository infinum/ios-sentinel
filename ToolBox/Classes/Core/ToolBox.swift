//
//  ToolBox.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

/// Defines singleton instance of the toolbox.
///
/// The toolbox can be configured with different configurations
/// and based on the configuration used will be triggered from
/// different events and show different tools.
public class ToolBox {
    
    private var configuration: Configuration?
    
    /// Singleton instance of the toolbox.
    public static let shared = ToolBox()
    
    private init() { }
    
    /// Setups the toolbox with provided configuration.
    ///
    /// - Parameter configuration: The configuration used to setup current instance of the toolbox.
    public func setup(with configuration: Configuration) {
        self.configuration = configuration
        configuration.trigger.subscribe { [weak self] in
            guard let viewController = configuration.sourceScreenProvider.viewControllerForShowingTools else { return }
            self?.present(tools: configuration.tools, on: viewController)
            
        }
    }
    
    /// Defines configuration used to define toolbox.
    ///
    /// Based on the provided properties, toolbox will be shown based on different event
    ///  and it will show different tools.
    public class Configuration {
        
        /// The trigger event which starts the toolbox.
        public let trigger: Trigger
        
        /// The screen used for presenting the toolbox.
        public let sourceScreenProvider: SourceScreenProvider
        
        /// Tools which are available from the toolbox.
        public let tools: [Tool]

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
        }
    }
    
}
