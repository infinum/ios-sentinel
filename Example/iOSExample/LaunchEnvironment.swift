//
//  LaunchEnvironment.swift
//  Example-iOS
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation

/// How the example app was launched: normally, as the host of the `Sentinel_Tests` bundle, or by the UI tests.
enum LaunchEnvironment {

    /// Passed by the UI tests in `XCUIApplication.launchArguments`.
    static let uiTestingArgument = "-uiTesting"
    /// Passed by the UI tests on a fresh launch, and left out when relaunching to check that state persisted.
    static let resetStateArgument = "-resetState"

    /// `true` while the app hosts the `Sentinel_Tests` bundle; those tests configure Sentinel themselves.
    static var isHostingUnitTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains(uiTestingArgument)
    }

    static var shouldResetState: Bool {
        isUITesting && ProcessInfo.processInfo.arguments.contains(resetStateArgument)
    }

    /// Starts every UI test from a clean slate: no saved defaults, no recorded crashes, no API mocks and no
    /// connection to a Mac.
    static func resetStateForUITests() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }
        // API mocks and the Mac connection are kept outside the folders Clear App Data empties, so they're
        // removed on their own.
        if let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
            for file in ["APIMocking.json", "MacConnection.json"] {
                try? FileManager.default.removeItem(at: library.appendingPathComponent("Sentinel/\(file)"))
            }
        }
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        for crashFile in ["nsexception_crashes.json", "signal_crashes.json"] {
            try? FileManager.default.removeItem(at: documents.appendingPathComponent(crashFile))
        }
    }
}
