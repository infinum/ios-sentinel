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
        guard let tools = ToolBox.shared.configuration?.tools.compactMap({ $0 as? CustomLocationTool }) else { return }
        let locations = tools.compactMap({ $0.locationProvider.customLocation })
        delegate?.locationManager?(self, didUpdateLocations: locations)
    }
}