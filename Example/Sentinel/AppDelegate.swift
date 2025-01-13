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
                colorChangeTool
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

    var optionSwitchItems: [ToolTableSection] {
        [
            .init(
                title: "UserDefaults flags",
                items: [
                    .toggle(
                        ToggleToolItem(
                            title: "Analytics",
                            userDefaults: .standard,
                            userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
                        )
                    ),
                    .toggle(
                        ToggleToolItem(
                            title: "Crashlytics",
                            setter: { AppSwitches.crashlyticsEnabled = $0 },
                            getter: { AppSwitches.crashlyticsEnabled }
                        )
                    ),
                    .toggle(
                        ToggleToolItem(
                            title: "Logging",
                            userDefaults: .standard,
                            userDefaultsKey: "com.infinum.sentinel.optionSwitch.logging"
                        )
                    )
                ]
            )

        ]

    }

}

