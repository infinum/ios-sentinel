//
//  CustomLocationProvider.swift
//  Sentinel
//
//  Created by Nikola Majcen on 01/10/2020.
//

import Foundation
import CoreLocation

private enum Constants {
    static let locationMockEnabledKey = "com.infinum.sentinel.locationMock.enabled"
    static let locationMockLocationKey = "com.infinum.sentinel.locationMock.location"
}

struct CustomLocationProvider {

    // MARK: - Private properties
    
    private var userDefaults: UserDefaults
    
    // MARK: - Lifecycle
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Internal methods
    
    var isCustomLocationUsageEnabled: Bool {
        userDefaults.bool(forKey: Constants.locationMockEnabledKey)
    }

    var customLocation: CLLocation? {
        guard
            let data = userDefaults.object(forKey: Constants.locationMockLocationKey) as? Data,
            let location = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: data)
        else { return nil }
        return location
    }

    func setCustomLocationUsageEnabled(_ enabled: Bool) {
        userDefaults.setValue(enabled, forKey: Constants.locationMockEnabledKey)
    }
    
    func setCustomLocation(location: CLLocation) {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
        userDefaults.setValue(data, forKey: Constants.locationMockLocationKey)
    }
}

// MARK: - Private methods

private extension CustomLocationProvider {

    func swizzleCustomLocationMethods() {
        guard
            let originalMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingLocation)),
            let swizzledMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingCustomLocation))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
