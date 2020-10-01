//
//  LocationMockTool.swift
//  ToolBox
//
//  Created by Nikola Majcen on 01/10/2020.
//

import Foundation

public class CustomLocationTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Private properties
    
    private let mocker = LocationMockUtility()
    
    // MARK: - Lifecycle
    
    public init(name: String = "Location Mock") {
        self.name = name
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let customLocationViewController = CustomLocationViewController.create(
            customLocationUtility: mocker
        )
        viewController.navigationController?.pushViewController(customLocationViewController, animated: true)
    }
}
