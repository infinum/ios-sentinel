//
//  CustomLocationProvider.swift
//  ToolBox
//
//  Created by Nikola Majcen on 01/10/2020.
//

import Foundation
import CoreLocation

class CustomLocationProvider {
    
    // MARK: - Constants
    
    private class Constants {
        private init() { }
        
        static let locationMockEnabledKey = "com.infinum.toolbox.locationMock.enabled"
        static let locationMockLatitudeKey = "com.infinum.toolbox.locationMock.latitude"
        static let locationMockLongitudeKey = "com.infinum.toolbox.locationMock.longitude"
    }
    
    // MARK: - Public properties
    
    static let instance = CustomLocationProvider()
    
    // MARK: - Lifecycle
    
    private init() { }
    
    // MARK: - Public methods
    
    func initializeCustomLocation(userDefaults: UserDefaults = .standard) {
        guard userDefaults.bool(forKey: Constants.locationMockEnabledKey) else { return }
        swizzleCustomLocationMethods()
    }
    
    func isCustomLocationUsageEnabled(userDefault: UserDefaults = .standard) -> Bool {
        return userDefault.bool(forKey: Constants.locationMockEnabledKey)
    }

    func setCustomLocationUsageEnabled(_ enabled: Bool, userDefaults: UserDefaults = .standard) {
        userDefaults.setValue(enabled, forKey: Constants.locationMockEnabledKey)
    }
    
    func setCustomLocation(latitude: Double, longitude: Double, userDefaults: UserDefaults = .standard) {
        userDefaults.setValue(latitude, forKey: Constants.locationMockLatitudeKey)
        userDefaults.setValue(longitude, forKey: Constants.locationMockLongitudeKey)
    }
    
    func customLocation(userDefaults: UserDefaults = .standard) -> CLLocation? {
        guard
            let latitude = userDefaults.object(forKey: Constants.locationMockLatitudeKey) as? Double,
            let longitude = userDefaults.object(forKey: Constants.locationMockLongitudeKey) as? Double
        else { return nil }

        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Private methods

private extension CustomLocationProvider {

    private func swizzleCustomLocationMethods() {
        guard
            let originalMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingLocation)),
            let swizzledMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingCustomLocation))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
