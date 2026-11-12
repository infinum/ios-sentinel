//
//  CustomLocationTool.swift
//  Sentinel
//
//  Created by Nikola Majcen on 01/10/2020.
//

import CoreLocation
import SwiftUI

#if os(iOS)

/// Tool which gives the ability to change current user location.
///
/// While the custom location is turned on, `startUpdatingLocation()` on any `CLLocationManager` delivers it
/// instead of the real location, so it applies the next time the app starts location updates.
public struct CustomLocationTool: Tool {

    // MARK: - Public properties
    
    public let name: String
    
    // MARK: - Internal properties

    let locationProvider: CustomLocationProvider

    // MARK: - Lifecycle
    
    public init(name: String = "Custom Location", userDefaults: UserDefaults = .standard) {
        self.name = name
        self.locationProvider = CustomLocationProvider(userDefaults: userDefaults)
        CLLocationManager.swizzleCustomLocation
    }
}

// MARK: - UI

public extension CustomLocationTool {

    var content: any View {
        CustomLocationView(locationProvider: locationProvider)
    }
}

#endif
