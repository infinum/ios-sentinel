//
//  CLLocationManager+CustomLocation.swift
//  ToolBox
//
//  Created by Nikola Majcen on 01/10/2020.
//

import CoreLocation

extension CLLocationManager {
    
    @objc
    internal func startUpdatingCustomLocation() {
        guard let location = CustomLocationProvider.instance.customLocation() else { return }
        DispatchQueue.main.async {
            self.delegate?.locationManager?(self, didUpdateLocations: [location])
        }
    }
}
