//
//  CustomLocationProviderTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

#if os(iOS)
import CoreLocation
import Testing
@testable import Sentinel

@Suite("Custom location provider")
struct CustomLocationProviderTests {

    private let isolatedDefaults = IsolatedUserDefaults()

    @Test("Nothing is stored by default")
    func defaults() {
        let provider = CustomLocationProvider(userDefaults: isolatedDefaults.defaults)

        #expect(!provider.isCustomLocationUsageEnabled)
        #expect(provider.customLocation == nil)
    }

    @Test("The enabled flag round-trips", arguments: [true, false])
    func enabledFlag(isEnabled: Bool) {
        let provider = CustomLocationProvider(userDefaults: isolatedDefaults.defaults)

        provider.setCustomLocationUsageEnabled(isEnabled)

        #expect(provider.isCustomLocationUsageEnabled == isEnabled)
    }

    @Test("A location round-trips through archiving")
    func locationRoundTrip() throws {
        let provider = CustomLocationProvider(userDefaults: isolatedDefaults.defaults)

        provider.setCustomLocation(location: CLLocation(latitude: 45.815, longitude: 15.982))

        let location = try #require(provider.customLocation)
        #expect(location.coordinate.latitude == 45.815)
        #expect(location.coordinate.longitude == 15.982)
    }

    @Test("Garbage data reads as no location")
    func invalidData() {
        isolatedDefaults.defaults.set(Data("garbage".utf8), forKey: "com.infinum.sentinel.locationMock.location")
        let provider = CustomLocationProvider(userDefaults: isolatedDefaults.defaults)

        #expect(provider.customLocation == nil)
    }

    @Test("The tool reads from the defaults it was given")
    func toolUsesInjectedDefaults() {
        CustomLocationProvider(userDefaults: isolatedDefaults.defaults).setCustomLocationUsageEnabled(true)

        let tool = CustomLocationTool(userDefaults: isolatedDefaults.defaults)

        #expect(tool.name == "Custom Location")
        #expect(tool.locationProvider.isCustomLocationUsageEnabled)
    }
}
#endif
