//
//  SourceScreenProvider.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objc
public protocol SourceScreenProvider: NSObjectProtocol {
    var viewControllerForShowingTools: UIViewController? { get }
}

@objcMembers
public class SourceScreenProviders: NSObject {
    
    // MARK: - Public providers
    
    @objc(defaultProvider)
    public static var `default`: SourceScreenProvider { DefaultSourceScreenProvider() }
    
    // MARK: - Lifecycle
    
    private override init() {
        super.init()
    }
}

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
