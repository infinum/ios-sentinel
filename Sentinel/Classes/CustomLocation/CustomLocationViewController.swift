//
//  CustomLocationViewController.swift
//  Sentinel
//
//  Created by Nikola Majcen on 01/10/2020.
//

import CoreLocation
import MapKit
import UIKit

extension UIStoryboard {
    static var customLocation: UIStoryboard { UIStoryboard(name: "CustomLocation", bundle: .sentinel) }
}

class CustomLocationViewController: UIViewController {
    
    fileprivate enum AlertDelay: Double {
        case normal = 0.33
        case long = 0.67
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var locationMockSwitch: UISwitch!
    @IBOutlet private weak var latitudeTextField: UITextField!
    @IBOutlet private weak var longitudeTextField: UITextField!
    @IBOutlet private weak var updateLocationButton: UIButton!
    @IBOutlet private weak var bottomOffset: NSLayoutConstraint!
    
    // MARK: - Private properties
    
    private var locationManager: CLLocationManager?
    private var locationProvider: CustomLocationProvider?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLocationManager()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Internal methods
    
    static func create(locationProvider: CustomLocationProvider) -> CustomLocationViewController {
        let viewController = UIStoryboard.customLocation.instantiateViewController(ofType: CustomLocationViewController.self)
        viewController.locationProvider = locationProvider
        return viewController
    }
    
    // MARK: - IBActions
    
    @IBAction func locationMockSwitchHandler(_ sender: UISwitch) {
        locationProvider?.setCustomLocationUsageEnabled(sender.isOn)
        let isEnabled = locationProvider?.isCustomLocationUsageEnabled ?? false
        configureButton(for: isEnabled, animated: true)
        showAlert(
            title: isEnabled ? "Custom location enabled" : "Custom location disabled",
            message: "To apply changes, please restart the application.",
            actionTitle: "OK",
            delay: .long
        )
    }
    
    @IBAction func updateLocationButtonActionHandler() {
        guard
            let latitude = coordinate(from: latitudeTextField.text),
            let longitude = coordinate(from: longitudeTextField.text)
        else {
            showAlert(
                title: "Incorrect location",
                message: "Please review entered latitude and longitude.",
                actionTitle: "OK",
                delay: .normal
            )
            return
        }
        locationProvider?.setCustomLocation(location: CLLocation(latitude: latitude, longitude: longitude))
        view.endEditing(true)
        showAlert(
            title: "Custom location changed",
            message: "To apply changes, please restart the application.",
            actionTitle: "OK",
            delay: .long
        )
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

extension CustomLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == latitudeTextField {
            latitudeTextField.resignFirstResponder()
            longitudeTextField.becomeFirstResponder()
        } else if (textField == longitudeTextField) {
            longitudeTextField.resignFirstResponder()
        }
        return false
    }
}

// MARK: - Private methods

private extension CustomLocationViewController {
    
    func configureView() {
        let customLocationEnabled = locationProvider?.isCustomLocationUsageEnabled ?? false
        configureSwitch(for: customLocationEnabled)
        configureFields(for: customLocationEnabled)
        configureButton(for: customLocationEnabled, animated: false)
        configureKeyboard()
    }
    
    func configureSwitch(for customLocationEnabled: Bool) {
        locationMockSwitch.setOn(customLocationEnabled, animated: false)
    }
    
    func configureFields(for customLocationEnabled: Bool) {
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        
        if customLocationEnabled, let coordinate = locationProvider?.customLocation?.coordinate {
            latitudeTextField.text = "\(coordinate.latitude)"
            longitudeTextField.text = "\(coordinate.longitude)"
        } else {
            latitudeTextField.text = nil
            longitudeTextField.text = nil
        }
    }
    
    func configureButton(for customLocationEnabled: Bool, animated: Bool) {
        let duration: Double = animated ? 0.33 : 0.0
        UIView.animate(withDuration: duration) {
            self.updateLocationButton.isHidden = !customLocationEnabled
            self.updateLocationButton.alpha = !customLocationEnabled ? 0 : 1
        }
    }
    
    func configureKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
    }
    
    func coordinate(from text: String?) -> Double? {
        guard let string = text, !string.isEmpty, let value = Double(string) else { return nil }
        return value
    }
    
    func showAlert(title: String, message: String, actionTitle: String, delay: AlertDelay) {
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(alertAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay.rawValue) {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            updateBottomConstraint(with: keyboardSize.height, notification: notification)
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        updateBottomConstraint(with: 0, notification: notification)
    }

    func updateBottomConstraint(with offset: CGFloat, notification: Notification) {
        bottomOffset.constant = offset
        let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}
