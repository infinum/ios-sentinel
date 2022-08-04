//
//  CustomLocationTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 01/10/2020.
//

import UIKit

/// Tool which gives the ability to change current user location.
///
/// When changing the user location, keep in mind that
/// every location change will be applied after
/// the application is restarted.
@objcMembers
public class CustomLocationTool: NSObject, Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Internal properties

    let locationProvider: CustomLocationProvider
    
    // MARK: - Lifecycle
    
    public init(name: String = "Custom Location", userDefaults: UserDefaults = .standard) {
        self.name = name
        self.locationProvider = CustomLocationProvider(userDefaults: userDefaults)
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let customLocationViewController = CustomLocationViewController.create(
            locationProvider: locationProvider
        )
        viewController.navigationController?.pushViewController(customLocationViewController, animated: true)
    }
}
