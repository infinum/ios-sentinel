//
//  SourceScreenProvider.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

public protocol SourceScreenProvider {
    var viewControllerForShowingTools: UIViewController? { get }
}

public enum SourceScreenProviders {
    public static var `default`: SourceScreenProvider { DefaultSourceScreenProvider() }
}

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
