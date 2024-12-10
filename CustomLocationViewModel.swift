//
//  CustomLocationViewModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.12.2024..
//

import Foundation
import MapKit

fileprivate enum AlertDelay: Double {
    case normal = 0.33
    case long = 0.67
}

struct MapItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

final class CustomLocationViewModel: ObservableObject {

    // MARK: - Internal properties -

    @Published var enableCustomLocation: Bool = false
    @Published var longitude: String = ""
    @Published var latitude: String = ""
    @Published var coordinateRegion: MKCoordinateRegion
    @Published var marker: MapItem?

    // MARK: - Private properties -

    private var locationManager: CLLocationManager?
    private let locationProvider: CustomLocationProvider

    // MARK: - Init -

    init(locationProvider: CustomLocationProvider) {
        self.locationProvider = locationProvider
        coordinateRegion = .init(center: CLLocationCoordinate2D(
            latitude: 54, longitude: 8),
            latitudinalMeters: 1000000, longitudinalMeters: 1000000)
    }

    // MARK: - Deinit -

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Extensions -

// MARK: - Handlers

extension CustomLocationViewModel {

    func updateLocation() {
        setLocation()
    }
}

private extension CustomLocationViewModel {

    func setLocation() {
        guard
            let latitude = coordinate(from: latitude),
            let longitude = coordinate(from: longitude)
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

        locationProvider.setCustomLocation(location: CLLocation(latitude: latitude, longitude: longitude))
    }

    func coordinate(from text: String) -> Double? {
        guard !text.isEmpty, let value = Double(text) else { return nil }
        return value
    }

    func addPinToLocation(using coordinates: CLLocationCoordinate2D) {
        coordinateRegion = .init(center: coordinates, latitudinalMeters: 1000000, longitudinalMeters: 1000000)
        marker = .init(coordinate: coordinates)
//        let allAnnotations = self.mapView.annotations
//        self.mapView.removeAnnotations(allAnnotations)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinates
//        mapView.addAnnotation(annotation)
    }

    func showAlert(title: String, message: String, actionTitle: String, delay: AlertDelay) {
//        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
//        let alertController = UIAlertController(
//            title: title,
//            message: message,
//            preferredStyle: .alert
//        )
//        alertController.addAction(alertAction)
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay.rawValue) {
//            self.present(alertController, animated: true, completion: nil)
//        }
    }

}
