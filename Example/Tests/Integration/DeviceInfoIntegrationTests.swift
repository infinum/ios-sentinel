//
//  DeviceInfoIntegrationTests.swift
//  Sentinel_Tests
//
//  Created by Nikola Simunko on 12.11.2026..
//

import Testing
import UIKit
@testable import Sentinel

extension IntegrationTests {

    @Suite("Device info")
    @MainActor
    struct DeviceInfoTests {

        // Only the "was off" case: the simulator ignores turning battery monitoring on, so the "was on"
        // case can't be set up here.
        @Test("Reading the battery state doesn't leave battery monitoring switched on")
        func batteryMonitoringIsRestored() {
            let device = UIDevice.current
            let original = device.isBatteryMonitoringEnabled
            defer { device.isBatteryMonitoringEnabled = original }
            device.isBatteryMonitoringEnabled = false

            _ = DeviceInfoProvider.batteryState

            #expect(!device.isBatteryMonitoringEnabled)
        }

        @Test("The screen section describes the foreground scene")
        func screenSection() {
            let rows = DeviceInfoProvider.screenSection.items.map(\.title)

            #expect(rows.starts(with: ["Screen size", "Screen resolution", "Screen scale", "Max refresh rate"]))
            #expect(rows.contains("Orientation"))
        }
    }
}
