//
//  LocationMockViewController.swift
//  ToolBox
//
//  Created by Nikola Majcen on 01/10/2020.
//

import CoreLocation
import MapKit
import UIKit

extension UIStoryboard {
    static var customLocation: UIStoryboard { UIStoryboard(name: "CustomLocation", bundle: .toolBox) }
}

class CustomLocationViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var locationMockSwitch: UISwitch!
    @IBOutlet private weak var latitudeTextField: UITextField!
    @IBOutlet private weak var longitudeTextField: UITextField!
    @IBOutlet private weak var updateLocationButton: UIButton!
    
    // MARK: - Private properties
    
    private var locationManager: CLLocationManager?
    private var locationMockUtility: LocationMockUtility?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        getCurrentLocation()
    }
    
    // MARK: - IBActions
    
    
    @IBAction func locationMockSwitchHandler(_ sender: UISwitch) {
        locationMockUtility?.setCustomLocationUsageEnabled(sender.isOn)
    }
    
    @IBAction func updateLocationButtonActionHandler(_ sender: UIButton) {
        if let latitude = coordinate(from: latitudeTextField.text),
           let longitude = coordinate(from: longitudeTextField.text) {
            locationMockUtility?.setCustomLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    // MARK: - Public methods
    
    static func create(customLocationUtility: LocationMockUtility) -> CustomLocationViewController {
        let viewController = UIStoryboard.customLocation.instantiateViewController(ofType: CustomLocationViewController.self)
        viewController.locationMockUtility = customLocationUtility
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
    
    func coordinate(from text: String?) -> Double? {
        guard let string = text, !string.isEmpty, let value = Double(string) else { return nil }
        return value
    }
}

extension CustomLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let center = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
    }
}

extension CustomLocationViewController: MKMapViewDelegate { }

class LocationMockUtility {
    
    // MARK: - Constants
    
    static let locationMockEnabledKey = "com.infinum.toolbox.locationMock.enabled"
    static let locationMockLatitudeKey = "com.infinum.toolbox.locationMock.latitude"
    static let locationMockLongitudeKey = "com.infinum.toolbox.locationMock.longitude"
    
    // MARK: - Private properties
    
    private let userDefaults: UserDefaults
    
    // MARK: - Lifecycle
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        initialize()
    }
    
    // MARK: - Public methods
    
    func setCustomLocationUsageEnabled(_ enabled: Bool) {
        userDefaults.setValue(enabled, forKey: LocationMockUtility.locationMockEnabledKey)
    }
    
    func setCustomLocation(latitude: Double, longitude: Double) {
        userDefaults.setValue(latitude, forKey: LocationMockUtility.locationMockLatitudeKey)
        userDefaults.setValue(longitude, forKey: LocationMockUtility.locationMockLongitudeKey)
    }
    
    static func customLocation() -> CLLocation? {
        guard
            let latitude = UserDefaults.standard.object(forKey: LocationMockUtility.locationMockLatitudeKey) as? Double,
            let longitude = UserDefaults.standard.object(forKey: LocationMockUtility.locationMockLongitudeKey) as? Double
        else { return nil }

        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Private methods
    
    private func initialize() {
        guard userDefaults.bool(forKey: LocationMockUtility.locationMockEnabledKey) else { return }
        swizzleLocationMethods()
    }
    
    private func swizzleLocationMethods() {
        guard
            let originalMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingLocation)),
            let swizzledMethod = class_getInstanceMethod(CLLocationManager.self, #selector(CLLocationManager.startUpdatingCustomLocation))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension CLLocationManager {
    
    @objc
    internal func startUpdatingCustomLocation() {
//        let locationMockUtility = LocationMockUtility()
        guard let location = LocationMockUtility.customLocation() else {
//            self.startUpdatingLocation()
            return
        }

        DispatchQueue.main.async {
            self.delegate?.locationManager?(self, didUpdateLocations: [location])
        }
    }
}
