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
        private let tool: CustomLocationTool

        init() {
            defaults = UserDefaults(suiteName: suiteName)!
            tool = CustomLocationTool(userDefaults: defaults)
            tool.locationProvider.setCustomLocationUsageEnabled(true)
            tool.locationProvider.setCustomLocation(location: CLLocation(latitude: 45.815, longitude: 15.982))
            Sentinel.shared.configuration = Sentinel.Configuration(tools: [tool])
        }

        deinit {
            Sentinel.shared.configuration = previousConfiguration
            defaults.removePersistentDomain(forName: suiteName)
        }

        @Test("Starting location updates delivers the custom location")
        func startUpdatingLocationUsesCustomLocation() async throws {
            let manager = CLLocationManager()
            let delegate = LocationDelegate()
            manager.delegate = delegate

            manager.startUpdatingLocation()
            try await Task.sleep(nanoseconds: 500_000_000)

            #expect(delegate.locations.map(\.coordinate.latitude) == [45.815])
            #expect(delegate.locations.map(\.coordinate.longitude) == [15.982])
        }

        @Test("With the custom location turned off, the real location updates start")
        func disabledCustomLocationIsIgnored() async throws {
            tool.locationProvider.setCustomLocationUsageEnabled(false)
            let manager = CLLocationManager()
            let delegate = LocationDelegate()
            manager.delegate = delegate

            manager.startUpdatingLocation()
            try await Task.sleep(nanoseconds: 500_000_000)
            manager.stopUpdatingLocation()

            #expect(!delegate.locations.contains { $0.coordinate.latitude == 45.815 })
        }

        @Test("Creating more tools doesn't swap the methods back")
        func swizzlingHappensOnce() async throws {
            _ = CustomLocationTool(userDefaults: defaults)
            _ = CustomLocationTool(userDefaults: defaults)
            let manager = CLLocationManager()
            let delegate = LocationDelegate()
            manager.delegate = delegate

            manager.startUpdatingLocation()
            try await Task.sleep(nanoseconds: 500_000_000)

            #expect(delegate.locations.map(\.coordinate.latitude) == [45.815])
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
