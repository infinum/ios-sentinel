//
//  AppDelegate.swift
//  Sentinel
//
//  Created by vlaho.poluta@infinum.hr on 07/30/2020.
//  Copyright (c) 2020 vlaho.poluta@infinum.hr. All rights reserved.
//

import UIKit
import Sentinel
import SentinelPulse
import Pulse

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard !LaunchEnvironment.isHostingUnitTests else { return true }
        if LaunchEnvironment.shouldResetState {
            LaunchEnvironment.resetStateForUITests()
        }
        setupSentinel()
        logSamplePulseEntries()
        return true
    }
}

enum AppUrl {
    static var baseURL = "http://google.com"
}

enum AppPreferences {
    static var analyticsEnabled = true
    static var crashlyticsEnabled = true
    static var loggingEnabled = false
    static var pickerValue = SomePickerValue.option1
}

enum SomePickerValue: String, CustomStringConvertible, CaseIterable {
    var description: String {
        self.rawValue
    }

    case option1, option2, option3
}

private extension AppDelegate {

    func setupSentinel() {
        let configuration = Sentinel.Configuration(
            trigger: Triggers.shake,
            tools: [
                UserDefaultsTool(),
                baseUrlTool,
                colorChangeTool,
                CrashDetectionTool(),
                ClearAppDataTool(),
                CustomLocationTool(),
                apiMockingTool,
                PulseTool()
            ],
            preferences: optionSwitchItems
        )

        Sentinel.shared.setup(with: configuration)
    }

    /// Gives the Pulse tool something to show: a few messages and one request logged through `URLSessionProxy`.
    func logSamplePulseEntries() {
        LoggerStore.shared.storeMessage(label: "app", level: .info, message: "Example app did finish launching")
        LoggerStore.shared.storeMessage(label: "app", level: .warning, message: "Sample warning logged by the example app")

        let session = URLSessionProxy(configuration: .default)
        Task {
            _ = try? await session.data(from: URL(string: "https://api.github.com/repos/infinum/ios-sentinel")!)
        }
    }

    /// Three answers to the request the menu's "Fetch repository" button makes.
    var apiMockingTool: Tool {
        APIMockingTool(
            mocks: [
                APIMock(
                    name: "Repository",
                    description: "Made-up repository details, read from repository.json",
                    group: "Repository",
                    method: .get,
                    url: .wildcard("/repos/infinum/ios-sentinel"),
                    body: .file(named: "repository")
                ),
                APIMock(
                    name: "Repository – server error",
                    description: "GitHub answers with a 500 after a second",
                    group: "Repository",
                    method: .get,
                    url: .wildcard("/repos/infinum/ios-sentinel"),
                    statusCode: 500,
                    body: .json(#"{ "message": "Server Error" }"#),
                    delay: 1
                ),
                APIMock(
                    name: "Repository – offline",
                    description: "The request fails as if the device had no connection",
                    group: "Repository",
                    url: .wildcard("/repos/infinum/ios-sentinel"),
                    error: .notConnectedToInternet,
                    delay: 2
                )
            ]
        )
    }

    var colorChangeTool: Tool {
        ToolTable(
            name: "Color Change Tool",
            sections: [
                ToolTableSection(title: "Color change", items: [.custom(ColorChangeToolTableItem())])
            ]
        )
    }

    var baseUrlTool: Tool {
        TextEditingTool(
            name: "Base URL",
            setter: { AppUrl.baseURL = $0 },
            getter: { AppUrl.baseURL },
            userDefaults: .standard,
            userDefaultsKey: "base_url_user_defaults_key"
        )
    }

    var optionSwitchItems: [PreferencesTool.Section] {
        [
            PreferencesTool.Section(
                title: "UserDefaults flags",
                items: [
                    ToggleToolItem(
                        title: "Analytics",
                        userDefaults: .standard,
                        userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
                    ),
                    ToggleToolItem(
                        title: "Crashlytics",
                        setter: { AppPreferences.crashlyticsEnabled = $0 },
                        getter: { AppPreferences.crashlyticsEnabled }
                    ),
                    ToggleToolItem(
                        title: "Logging",
                        description: "It is used to turn the Logging on or off",
                        userDefaults: .standard,
                        userDefaultsKey: "com.infinum.sentinel.optionSwitch.logging"
                    ),
                    PreferencesTextItem(
                        title: "name",
                        description: "Saves the current name into user defaults",
                        userDefaultsKey: "com.infinum.sentinel.name"
                    ),
                    PreferencesIntItem(
                        title: "some number",
                        description: "number from 3 to 10",
                        validators: [AnyPreferenceValidator(validator: PreferenceValueValidator(min: 3, max: 10, validationMessage: "value has to be in the range"))],
                        userDefaultsKey: "com.inifnum.sentinel.number"
                    ),
                    PreferencesPickerItem(
                        title: "Picker values",
                        values: SomePickerValue.allCases,
                        setter: { value in AppPreferences.pickerValue = value as! SomePickerValue },
                        getter: { AppPreferences.pickerValue }
                    )
                ]
            )

        ]

    }

}
