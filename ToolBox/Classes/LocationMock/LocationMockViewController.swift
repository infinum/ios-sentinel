//
//  LocationMockViewController.swift
//  ToolBox
//
//  Created by Nikola Majcen on 01/10/2020.
//

import UIKit
import CoreLocation

extension UIStoryboard {
    static var locationMock: UIStoryboard { UIStoryboard(name: "LocationMock", bundle: .toolBox) }
}

class LocationMockViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var latitudeTextField: UITextField!
    @IBOutlet private weak var longitudeTextField: UITextField!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentLocation()
    }
    
    // MARK: - IBActions
    
    @IBAction func saveButtonActionHandler(_ sender: UIButton) {
        let mocker = LocationMocker()
        mocker.setValues(lat: 37.334481, long: -122.009118)
        mocker.setEnabled(true)
    }
    
    // MARK: - Public methods
    
    static func create() -> LocationMockViewController {
        let viewController = UIStoryboard.locationMock.instantiateViewController(ofType: LocationMockViewController.self)
        return viewController
    }
    
    // MARK: - Private methods
    
    private var manager: CLLocationManager?
    
    func getCurrentLocation() {
        manager = CLLocationManager()
        manager?.requestWhenInUseAuthorization()
        manager?.startUpdatingLocation()
        manager?.delegate = self
    }
}

extension LocationMockViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
}

class LocationMocker {
    
    var lat: Double?
    var long: Double?
    
    let userDefaults = UserDefaults.standard
    
    func setValues(lat: Double, long: Double) {
        self.lat = lat
        self.long = long
    }
    
    func setEnabled(_ enabled: Bool) {
        userDefaults.setValue(enabled, forKey: "locationMockerEnabled")
        if let lat = self.lat, let long = self.long {
            userDefaults.setValue(lat, forKey: "locationMockerLat")
            userDefaults.setValue(long, forKey: "locationMockerLong")
        }
    }
    
    func initializeMock() {
        if userDefaults.bool(forKey: "locationMockerEnabled") == true {
            // Swizzle
            
            if let originalMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingLocation)),
               let swizzledMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingLocationMock)) {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
            
        } else {
            // Everything is fine, just chill :)
        }
    }
}

extension CLLocationManager {
    
    @objc func startUpdatingLocationMock() {
        let lat = UserDefaults.standard.double(forKey: "locationMockerLat")
        let long = UserDefaults.standard.double(forKey: "locationMockerLong")
        
        let location = CLLocation(latitude: lat, longitude: long)
        DispatchQueue.main.async {
            self.delegate?.locationManager?(self, didUpdateLocations: [location])
        }
    }
    
}
