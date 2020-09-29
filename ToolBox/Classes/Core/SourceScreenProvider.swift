//
//  SourceScreenProvider.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

/// Defines source screen which will be used to present toolbox when triggered.
public protocol SourceScreenProvider {
    /// The view controller used for presenting the toolbox.
    var viewControllerForShowingTools: UIViewController? { get }
}

/// Provides possible source screens used for presenting the toolbox.
public enum SourceScreenProviders {
    /// Default source screen provider.
    public static var `default`: SourceScreenProvider { DefaultSourceScreenProvider() }
}

/// Defines detauls source screen provider used for presenting the toolbox.
public class DefaultSourceScreenProvider: SourceScreenProvider {
    
    public var viewControllerForShowingTools: UIViewController? { topMostController() }
    
    private func topMostController() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return nil
        }

        var topController = rootViewController

        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        return topController
    }
}
