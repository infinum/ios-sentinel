//
//  OptionSwitchTool.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import Foundation

public class OptionSwitchTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Lifecycle
    
    public init(name: String = "Option Switch Tool") {
        self.name = name
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let optionSwitchViewController = OptionSwitchViewController.create()
        viewController.navigationController?.pushViewController(optionSwitchViewController, animated: true)
    }
}
