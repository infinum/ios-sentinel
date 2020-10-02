//
//  PerformanceInfoTool.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

public class PerformanceInfoTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Lifecycle
    
    public init(name: String = "Performance Info") {
        self.name = name
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let performanceInfoViewController = PerformanceInfoViewController.create()
        viewController.navigationController?.pushViewController(performanceInfoViewController, animated: true)
    }
}
