//
//  AppDelegate.swift
//  Sentinel
//
//  Created by vlaho.poluta@infinum.hr on 07/30/2020.
//  Copyright (c) 2020 vlaho.poluta@infinum.hr. All rights reserved.
//

import UIKit
import Sentinel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupSentinel()
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
                CrashDetectionTool()
            ],
            preferences: optionSwitchItems
        )

        Sentinel.shared.setup(with: configuration)
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
                    PreferencesTextItem(title: "name", description: "Saves the current name into user defaults", userDefaultsKey: "com.infinum.sentinel.name"),
                    PreferencesIntItem(title: "some number", userDefaultsKey: "com.inifnum.sentinel.number"),
                    PreferencesPickerItem(
                        title: "Picker values",
                        values: SomePickerValue.allCases,
                        setter: { value in AppPreferences.pickerValue = value as! SomePickerValue },
                        getter: { AppPreferences.pickerValue })
                ]
            )

        ]

    }

}
