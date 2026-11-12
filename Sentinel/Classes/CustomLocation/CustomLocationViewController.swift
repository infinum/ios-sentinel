//
//  CustomLocationViewController.swift
//  Sentinel
//
//  Created by Nikola Majcen on 01/10/2020.
//

#if os(iOS)

import CoreLocation
import MapKit
import UIKit

final class CustomLocationViewController: UIViewController {

    fileprivate enum AlertDelay: Double {
        case normal = 0.33
        case long = 0.67
    }
    
    // MARK: - Views
    
    private let gestureInfoLabel = CustomLocationViewController.makeLabel(text: "Long press to change location", font: .systemFont(ofSize: 13))
    private let mapView = MKMapView()
    private let locationMockSwitch = UISwitch()
    private let latitudeTextField = CustomLocationViewController.makeTextField(placeholder: "Enter latitude", returnKeyType: .next)
    private let longitudeTextField = CustomLocationViewController.makeTextField(placeholder: "Enter longitude", returnKeyType: .done)
    private let updateLocationButton = UIButton(type: .system)
    private var bottomOffset: NSLayoutConstraint!
    
    // MARK: - Private properties
    
    private var locationManager: CLLocationManager?
    private var locationProvider: CustomLocationProvider?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureView()
        configureLocationManager()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Internal methods
    
    static func create(locationProvider: CustomLocationProvider) -> CustomLocationViewController {
        let viewController = CustomLocationViewController()
        viewController.locationProvider = locationProvider
        return viewController
    }
    
    // MARK: - Actions
    
    @objc func locationMockSwitchHandler(_ sender: UISwitch) {
        locationProvider?.setCustomLocationUsageEnabled(sender.isOn)
        let isEnabled = locationProvider?.isCustomLocationUsageEnabled ?? false
        handleInfoLabelVisibility()
        configureButton(for: isEnabled, animated: true)
        showAlert(
            title: isEnabled ? "Custom location enabled" : "Custom location disabled",
            message: "To apply changes, please restart the application.",
            actionTitle: "OK",
            delay: .long
        )
    }

    @objc func updateLocationButtonActionHandler() {
        setLocation()
    }
}

// MARK: - CLLocationManagerDelegate conformance

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

// MARK: - MKMapViewDelegate conformance

extension CustomLocationViewController: MKMapViewDelegate { }

// MARK: - UITextFieldDelegate conformance

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

// MARK: - Layout

private extension CustomLocationViewController {

    func configureLayout() {
        view.backgroundColor = .systemBackground

        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.delegate = self

        locationMockSwitch.addTarget(self, action: #selector(locationMockSwitchHandler), for: .valueChanged)

        updateLocationButton.setTitle("Update", for: .normal)
        updateLocationButton.setTitleColor(.white, for: .normal)
        updateLocationButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        updateLocationButton.backgroundColor = .systemBlue
        updateLocationButton.layer.cornerRadius = 8
        updateLocationButton.addTarget(self, action: #selector(updateLocationButtonActionHandler), for: .touchUpInside)

        let switchStackView = UIStackView(arrangedSubviews: [
            Self.makeLabel(text: "Custom location", font: .systemFont(ofSize: 16, weight: .medium)),
            locationMockSwitch
        ])
        switchStackView.alignment = .center

        let switchContainerView = UIView()
        switchContainerView.backgroundColor = .systemBackground
        switchContainerView.layer.cornerRadius = 8

        let fieldsStackView = UIStackView(arrangedSubviews: [
            gestureInfoLabel,
            Self.makeFieldStackView(title: "Latitude", textField: latitudeTextField),
            Self.makeFieldStackView(title: "Longitude", textField: longitudeTextField),
            updateLocationButton
        ])
        fieldsStackView.axis = .vertical
        fieldsStackView.spacing = 24

        let fieldsContainerView = UIView()
        fieldsContainerView.backgroundColor = .systemBackground

        // Fills the gap below the fields container, which is pinned to the safe area and lifted by the keyboard.
        let bottomFillerView = UIView()
        bottomFillerView.backgroundColor = .systemBackground

        [mapView, switchContainerView, fieldsContainerView, bottomFillerView].forEach(view.addSubview)
        switchContainerView.addSubview(switchStackView)
        fieldsContainerView.addSubview(fieldsStackView)
        [mapView, switchContainerView, switchStackView, fieldsContainerView, fieldsStackView, bottomFillerView, updateLocationButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let safeArea = view.safeAreaLayoutGuide
        bottomOffset = safeArea.bottomAnchor.constraint(equalTo: fieldsContainerView.bottomAnchor)
        bottomOffset.priority = .required - 1

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75),

            switchContainerView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            switchContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            switchContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),

            switchStackView.topAnchor.constraint(equalTo: switchContainerView.topAnchor, constant: 12),
            switchStackView.leadingAnchor.constraint(equalTo: switchContainerView.leadingAnchor, constant: 16),
            switchStackView.trailingAnchor.constraint(equalTo: switchContainerView.trailingAnchor, constant: -16),
            switchStackView.bottomAnchor.constraint(equalTo: switchContainerView.bottomAnchor, constant: -12),

            fieldsContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            fieldsContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            fieldsContainerView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            bottomOffset,

            fieldsStackView.topAnchor.constraint(equalTo: fieldsContainerView.topAnchor, constant: 16),
            fieldsStackView.leadingAnchor.constraint(equalTo: fieldsContainerView.leadingAnchor, constant: 16),
            fieldsStackView.trailingAnchor.constraint(equalTo: fieldsContainerView.trailingAnchor, constant: -16),
            fieldsStackView.bottomAnchor.constraint(equalTo: fieldsContainerView.bottomAnchor, constant: -16),

            updateLocationButton.heightAnchor.constraint(equalToConstant: 44),

            bottomFillerView.topAnchor.constraint(equalTo: fieldsContainerView.bottomAnchor),
            bottomFillerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomFillerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomFillerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    static func makeLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        return label
    }

    static func makeTextField(placeholder: String, returnKeyType: UIReturnKeyType) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 14)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = returnKeyType
        return textField
    }

    static func makeFieldStackView(title: String, textField: UITextField) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            makeLabel(text: title, font: .systemFont(ofSize: 16)),
            textField
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
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
        addGesture()
        handleInfoLabelVisibility()
        checkForExistingCoordinates()
    }

    func addGesture() {
        let longGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(addCustomLocation(longGesture:))
        )
        mapView.addGestureRecognizer(longGesture)
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
        guard let string = text, !string.isEmpty else { return nil }
        return Double(string)
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
    
    @objc func addCustomLocation(longGesture: UIGestureRecognizer) {
        let isEnabled = locationProvider?.isCustomLocationUsageEnabled ?? false
        guard isEnabled else { return }
        let touchPoint = longGesture.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        latitudeTextField.text = "\(newCoordinates.latitude)"
        longitudeTextField.text = "\(newCoordinates.longitude)"
        addPinToLocation(using: newCoordinates)
    }

    func setLocation() {
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

        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        addPinToLocation(using: coordinates)

        locationProvider?.setCustomLocation(location: CLLocation(latitude: latitude, longitude: longitude))
        view.endEditing(true)
        showAlert(
            title: "Custom location changed",
            message: "To apply changes, please restart the application.",
            actionTitle: "OK",
            delay: .long
        )
    }

    func handleInfoLabelVisibility() {
        let isEnabled = locationProvider?.isCustomLocationUsageEnabled ?? false
        gestureInfoLabel.isHidden = !isEnabled
    }

    func checkForExistingCoordinates() {
        guard
            let latitude = coordinate(from: latitudeTextField.text),
            let longitude = coordinate(from: longitudeTextField.text)
        else { return }
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        addPinToLocation(using: coordinates)
    }

    func addPinToLocation(using coordinates: CLLocationCoordinate2D) {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }

}

#endif
