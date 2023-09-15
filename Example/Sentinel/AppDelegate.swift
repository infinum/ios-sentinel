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

enum AppSwitches {
    static var analyticsEnabled = true
    static var crashlyticsEnabled = true
    static var loggingEnabled = false
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
            preferences: preferences
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

    /// Simple switch items that can be toggled on or off.
    var preferences: [PreferenceItem] {
        return [
            // Old API values:
            .init(
                name: "Analytics",
                setter: { AppSwitches.analyticsEnabled = $0 },
                getter: { AppSwitches.analyticsEnabled },
                userDefaults: .standard,
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
            ),
            .init(
                name: "Crashlytics",
                setter: { AppSwitches.crashlyticsEnabled = $0 },
                getter: { AppSwitches.crashlyticsEnabled },
                userDefaults: .standard,
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.crashlytics"
            ),
            .init(
                name: "Logging",
                setter: { AppSwitches.loggingEnabled = $0 },
                getter: { AppSwitches.loggingEnabled },
                userDefaults: .standard,
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.logging"
            ),
            // New API values:
            .init(
                textName: "Name",
                info: "From 1 to 5",
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.name",
                onDidSet: nil
            ),
            .init(
                integerName: "Star Rating",
                info: "From 1 to 5",
                min: 1,
                max: 5,
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.starRating",
                onDidSet: nil
            ),
            .init(
                doubleName: "Temperature",
                info: "Decimal number",
                min: -50,
                max: 50,
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.temperature",
                onDidSet: { [weak self] in self?.didChange(temperature: $0) }
            ),
            .init(
                enumName: "Weekday",
                enumType: Weekday.self,
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.weekdays",
                onDidSet: { [weak self] in self?.didChange(weekday: $0) }
            ),
            .init(
                enumName: "Direction",
                enumType: Direction.self,
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.direction",
                onDidSet: { [weak self] in self?.didChange(direction: $0) }
            ),
            .init(
                boolName: "Placeholder Mode",
                info: "Hides images when turned on",
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.placeholderMode",
                onDidSet: { [weak self] in self?.didChange(isPlaceholderModeOn: $0) }
            )
        ]
    }

    func didChange(temperature: Double?) {
        guard let temperature else {
            print("Temperature deleted")
            return
        }
        print("Temperature Set:", temperature > 0 ? "💧" : "🧊")
    }

    func didChange(weekday: Weekday?) {
        guard let weekday else {
            print("Weekday deleted")
            return
        }
        print("Weekday Set:", weekday == .saturday || weekday == .sunday ? "🎉" : "💼")
    }

    func didChange(direction: Direction?) {
        print("Direction Set:", direction ?? "nil")
    }

    func didChange(isPlaceholderModeOn: Bool) {
        print("Placeholder mode:", isPlaceholderModeOn ? "✅" : "❌")
    }

}
