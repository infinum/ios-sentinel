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
        static let locationMockLocationKey = "com.infinum.toolbox.locationMock.location"
    }

    // MARK: - Private properties
    
    private var userDefaults: UserDefaults
    
    // MARK: - Lifecycle
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public methods
    
    var isCustomLocationUsageEnabled: Bool {
        return userDefaults.bool(forKey: Constants.locationMockEnabledKey)
    }

    var customLocation: CLLocation? {
        guard
            let data = userDefaults.object(forKey: Constants.locationMockLocationKey) as? Data,
            let location = NSKeyedUnarchiver.unarchiveObject(with: data) as? CLLocation
        else { return nil }
        return location
    }

    func setCustomLocationUsageEnabled(_ enabled: Bool) {
        userDefaults.setValue(enabled, forKey: Constants.locationMockEnabledKey)
    }
    
    func setCustomLocation(location: CLLocation) {
        let data = NSKeyedArchiver.archivedData(withRootObject: location)
        userDefaults.setValue(data, forKey: Constants.locationMockLocationKey)
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
