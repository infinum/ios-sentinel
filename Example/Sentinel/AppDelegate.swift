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
    static var textInput = "text"
}

private extension AppDelegate {
    
    func setupSentinel() {
        let configuration = Sentinel.Configuration(
            trigger: Triggers.shake,
            tools: [
                UserDefaultsTool(),
                baseUrlTool,
                CustomLocationTool()
//                CollarTool(),
//                LoggieTool()
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
    
    var optionSwitchItems: [any PreferenceItem] {
       [
        // This class is used here to check if the code is backward compatible.
        OptionSwitchItem(
            name: "Analytics",
            setter: { AppPreferences.analyticsEnabled = $0 },
            getter: { AppPreferences.analyticsEnabled },
            userDefaults: .standard,
            userDefaultsKey: "com.infinum.sentinel.switch.analytics"
        ),
        PreferenceSwitchItem(
            name: "Crashlytics",
            setter: { AppPreferences.crashlyticsEnabled = $0 },
            getter: { AppPreferences.crashlyticsEnabled },
            userDefaults: .standard,
            userDefaultsKey: "com.infinum.sentinel.switch.crashlytics"
        ),
        PreferenceSwitchItem(
            name: "Logging",
            setter: { AppPreferences.loggingEnabled = $0 },
            getter: { AppPreferences.loggingEnabled },
            userDefaults: .standard,
            userDefaultsKey: "com.infinum.sentinel.switch.logging"
        ),
        PreferenceTextItem(
            name: "Text input",
            setter: { AppPreferences.textInput = $0 },
            getter: { AppPreferences.textInput },
            validator: { $0.count <= 5 },
            userDefaults: .standard,
            userDefaultsKey: "com.infinum.sentinel.text.inputText"
        )
       ]

    }
    
}

