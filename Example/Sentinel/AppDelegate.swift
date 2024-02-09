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
            // MARK: Old API values:
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
            // MARK: New API values:
             .init(
                type: String.self, name: "Name",
                info: "Up to 50 chars",
                validator: { $0.count < 50 },
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.name",
                onDidSet: {
                    print("Did set:", $0?.uppercased() ?? "<nil>")
                }
            ),
            .init(
                type: Int.self,
                name: "Star Rating",
                info: "From 1 to 5",
                validator: { $0 >= 1 && $0 <= 5 },
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.starRating",
                onDidSet: {
                    print("Did set integer. isEven=", $0?.isMultiple(of: 2) ?? false)
                }
            ),
            .init(
                type: Double.self,
                name: "Temperature",
                info: "Decimal number, between -50 and +50.",
                validator: { abs($0) <= 50 },
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.temperature",
                onDidSet: { [weak self] in self?.didChange(temperature: $0) }
            ),
            .init(
                enumType: Weekday.self,
                name: "Weekday",
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.weekdays",
                onDidSet: { [weak self] in self?.didChange(weekday: $0) }
            ),
            .init(
                type: Bool.self,
                name: "Placeholder Mode",
                info: "Hides images when turned on",
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.placeholderMode",
                onDidSet: { [weak self] in self?.didChange(isPlaceholderModeOn: $0 ?? false) }
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
