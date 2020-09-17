//
//  ToolBox.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objcMembers
public class ToolBox: NSObject {
    
    // MARK: - Private properties
    
    private var configuration: Configuration?

    // MARK: - Public properties
    
    @objc(sharedInstance)
    public static let shared = ToolBox()
    
    // MARK: - Lifecycle
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public methods
    
    @objc(setupWithConfiguration:)
    public func setup(with configuration: Configuration) {
        self.configuration = configuration
        configuration.trigger.subscribe { [weak self] in
            guard let viewController = configuration.sourceScreenProvider.viewControllerForShowingTools else { return }
            self?.present(tools: configuration.tools, on: viewController)
            
        }
    }
    
    // MARK: - Inner classes
    
    @objcMembers
    public class Configuration: NSObject {
        
        // MARK: - Public properties
        
        public let trigger: Trigger
        public let sourceScreenProvider: SourceScreenProvider
        public let tools: [Tool]
        
        // MARK: - Lifecycle

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
