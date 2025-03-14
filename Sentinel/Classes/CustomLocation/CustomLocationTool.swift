//
//  CustomLocationTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 01/10/2020.
//

import SwiftUI

/// Tool which gives the ability to change current user location.
///
/// Chaniging the user location will be applied after the application has been restarted.
public struct CustomLocationTool: Tool {

    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Internal properties

    let locationProvider: CustomLocationProvider

    // MARK: - Lifecycle
    
    public init(name: String = "Custom Location", userDefaults: UserDefaults = .standard) {
        self.name = name
        self.locationProvider = CustomLocationProvider(userDefaults: userDefaults)
    }
}

// MARK: - UI

public extension CustomLocationTool {

    var content: any View {
        CustomLocationView(locationProvider: locationProvider)
    }
}
