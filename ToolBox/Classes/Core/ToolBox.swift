//
//  ToolBox.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

public class ToolBox {
    
    private init() {}
    public static let shared = ToolBox()
    private var configuration: Configuration?
    
    public func setup(with configuration: Configuration) {
        self.configuration = configuration
        configuration.trigger.subscribe { [weak self] in
            guard let viewController = configuration.sourceScreenProvider.viewControllerForShowingTools else { return }
            self?.present(tools: configuration.tools, on: viewController)
            
        }
    }
    
    public class Configuration {
        public let trigger: Trigger
        public let sourceScreenProvider: SourceScreenProvider
        public let tools: [Tool]

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
