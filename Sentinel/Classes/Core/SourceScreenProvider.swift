//
//  SourceScreenProvider.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

/// Defines source screen which will be used to present toolbox when triggered.
@objc
public protocol SourceScreenProvider: NSObjectProtocol {

    /// The view controller used for presenting the toolbox.
    var viewControllerForShowingTools: UIViewController? { get }
}

/// Provides possible source screens used for presenting the toolbox.
@objcMembers
public class SourceScreenProviders: NSObject {
    
    // MARK: - Public providers
    
    /// Default source screen provider.
    @objc(defaultProvider)
    public static var `default`: SourceScreenProvider { DefaultSourceScreenProvider() }
    
    // MARK: - Lifecycle
    
    private override init() {
        super.init()
    }
}

/// Defines detauls source screen provider used for presenting the toolbox.
@objcMembers
public class DefaultSourceScreenProvider: NSObject, SourceScreenProvider {
    
    // MARK: - Public properties
    
    public var viewControllerForShowingTools: UIViewController? { topMostController() }
    
    // MARK: - Private methods
    
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
