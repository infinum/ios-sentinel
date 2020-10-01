//
//  LocationMockTool.swift
//  ToolBox
//
//  Created by Nikola Majcen on 01/10/2020.
//

import Foundation

public class LocationMockTool: Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Private properties
    
    private let userDefaults: UserDefaults
    
    // MARK: - Lifecycle
    
    public init(name: String = "Location Mock", userDefaults: UserDefaults = .standard) {
        self.name = name
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let locationMockViewController = LocationMockViewController.create()
        viewController.navigationController?.pushViewController(locationMockViewController, animated: true)
    }
}
