//
//  Tool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

/// Defines tool behaviour.
public protocol Tool {
    /// The name of the tool.
    var name: String { get }
    
    /// Presents the tool view controller from provided view controller.
    ///
    /// - Parameter viewController: The view controller used for presenting tool view controller.
    func presentPreview(from viewController: UIViewController)
}
