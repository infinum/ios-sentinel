//
//  CustomLocationViewController.swift
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
    private var locationProvider: CustomLocationProvider?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureLocationManager()
    }
    
    // MARK: - Public methods
    
    static func create(locationProvider: CustomLocationProvider) -> CustomLocationViewController {
        let viewController = UIStoryboard.customLocation.instantiateViewController(ofType: CustomLocationViewController.self)
        viewController.locationProvider = locationProvider
        return viewController
    }
    
    // MARK: - IBActions
    
    @IBAction func locationMockSwitchHandler(_ sender: UISwitch) {
        locationProvider?.setCustomLocationUsageEnabled(sender.isOn)
    }
    
    @IBAction func updateLocationButtonActionHandler(_ sender: UIButton) {
        guard
            let latitude = coordinate(from: latitudeTextField.text),
            let longitude = coordinate(from: longitudeTextField.text)
        else { return }
        locationProvider?.setCustomLocation(latitude: latitude, longitude: longitude)
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

// MARK: - Private methods

private extension CustomLocationViewController {
    
    func configureMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = false
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
    }
    
    func coordinate(from text: String?) -> Double? {
        guard let string = text, !string.isEmpty, let value = Double(string) else { return nil }
        return value
    }
}
