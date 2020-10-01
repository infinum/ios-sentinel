//
//  CustomLocationTool.swift
//  ToolBox
//
//  Created by Nikola Majcen on 01/10/2020.
//

import Foundation

public class CustomLocationTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Private properties

    private let locationProvider = CustomLocationProvider.instance
    
    // MARK: - Lifecycle
    
    public init(name: String = "Custom Location") {
        self.name = name
        self.locationProvider.initializeCustomLocation()
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let customLocationViewController = CustomLocationViewController.create(
            locationProvider: locationProvider
        )
        viewController.navigationController?.pushViewController(customLocationViewController, animated: true)
    }
}
