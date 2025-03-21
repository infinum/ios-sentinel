//
//  AppDelegate.swift
//  MacOSExample
//
//  Created by Zvonimir Medak on 20.01.2025..
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Cocoa
import AppKit
import Sentinel

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

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        setupSentinel()
    }
}

private extension AppDelegate {

    func setupSentinel() {
        let configuration = Sentinel.Configuration(
            trigger: Triggers.notification(forName: Notification.Name("SomeValue")),
            tools: [
                UserDefaultsTool(),
                baseUrlTool,
                CrashDetectionTool()
            ],
            preferences: optionSwitchItems
        )

        Sentinel.shared.setup(with: configuration)
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
