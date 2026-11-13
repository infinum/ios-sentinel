//
//  CLLocationManager+CustomLocation.swift
//  Sentinel
//
//  Created by Nikola Majcen on 01/10/2020.
//

import CoreLocation

#if os(iOS)

extension CLLocationManager {

    /// Exchanges `startUpdatingLocation` with `startUpdatingCustomLocation` for every location manager.
    /// A static stored property runs only once, so creating several tools can't swap the methods back.
    static let swizzleCustomLocation: Void = {
        guard
            let originalMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingLocation)),
            let swizzledMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingCustomLocation))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    /// Runs in place of `startUpdatingLocation` once the methods are exchanged.
    @objc
    func startUpdatingCustomLocation() {
        let locations = (Sentinel.shared.configuration?.tools ?? [])
            .compactMap { ($0 as? CustomLocationTool)?.locationProvider }
            .filter(\.isCustomLocationUsageEnabled)
            .compactMap(\.customLocation)
        guard !locations.isEmpty else {
            // After the exchange, this selector points at the original `startUpdatingLocation`.
            startUpdatingCustomLocation()
            return
        }
        // Real updates arrive asynchronously, so callers can finish setting up before the delegate is called.
        // CLLocationManager calls its delegate on the run loop of the thread that created it; that's the main
        // thread for almost every app, so the main queue is used. The configuration above is read on
        // whichever thread called `startUpdatingLocation()`.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            delegate?.locationManager?(self, didUpdateLocations: locations)
        }
    }
}

#endif
