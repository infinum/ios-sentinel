//
//  CustomLocationIntegrationTests.swift
//  Sentinel_Tests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import CoreLocation
import Testing
@testable import Sentinel

extension IntegrationTests {

    @Suite("Custom location")
    @MainActor
    final class CustomLocationIntegrationTests {

        private let suiteName = "com.infinum.sentinel.tests.\(UUID().uuidString)"
        private let defaults: UserDefaults
        private let previousConfiguration = Sentinel.shared.configuration

        init() {
            defaults = UserDefaults(suiteName: suiteName)!
            let tool = CustomLocationTool(userDefaults: defaults)
            tool.locationProvider.setCustomLocationUsageEnabled(true)
            tool.locationProvider.setCustomLocation(location: CLLocation(latitude: 45.815, longitude: 15.982))
            Sentinel.shared.configuration = Sentinel.Configuration(tools: [tool])
        }

        deinit {
            Sentinel.shared.configuration = previousConfiguration
            defaults.removePersistentDomain(forName: suiteName)
        }

        @Test("The custom location is delivered to the manager's delegate")
        func customLocationIsDelivered() {
            let manager = CLLocationManager()
            let delegate = LocationDelegate()
            manager.delegate = delegate

            manager.startUpdatingCustomLocation()

            #expect(delegate.locations.map(\.coordinate.latitude) == [45.815])
            #expect(delegate.locations.map(\.coordinate.longitude) == [15.982])
        }

        @Test("Starting location updates delivers the custom location")
        func startUpdatingLocationUsesCustomLocation() async throws {
            let manager = CLLocationManager()
            let delegate = LocationDelegate()
            manager.delegate = delegate

            manager.startUpdatingLocation()
            try await Task.sleep(nanoseconds: 500_000_000)
            manager.stopUpdatingLocation()

            withKnownIssue("swizzleCustomLocationMethods() is never called, so startUpdatingLocation isn't redirected") {
                #expect(delegate.locations.contains { $0.coordinate.latitude == 45.815 })
            }
        }
    }
}

private final class LocationDelegate: NSObject, CLLocationManagerDelegate {

    private(set) var locations: [CLLocation] = []

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations += locations
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
