//
//  AppDelegate.swift
//  ToolBox
//
//  Created by vlaho.poluta@infinum.hr on 07/30/2020.
//  Copyright (c) 2020 vlaho.poluta@infinum.hr. All rights reserved.
//

import UIKit
import ToolBox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupToolBox()
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
    
    func setupToolBox() {
        let configuration = ToolBox.Configuration(
            trigger: Triggers.shake,
            tools: [
                GeneralInfoTool(),
                UserDefaultsTool(),
                baseUrlTool,
//                BugsnatchTool(triggerActionConfig: EmailConfig()),
//                LoggieTool(),
//                AnalyticsCollectorTool(),
                optionSwitchTool,
            ]
        )
        
        ToolBox.shared.setup(with: configuration)
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
    
    var optionSwitchTool: Tool {
        OptionSwitchTool(
            items: [
                OptionSwitchItem(
                    name: "Analytics",
                    setter: { AppSwitches.analyticsEnabled = $0 },
                    getter: { AppSwitches.analyticsEnabled },
                    userDefaults: .standard,
                    userDefaultsKey: "com.infinum.toolbox.optionSwitch.analytics"
                ),
                OptionSwitchItem(
                    name: "Crashlytics",
                    setter: { AppSwitches.crashlyticsEnabled = $0 },
                    getter: { AppSwitches.crashlyticsEnabled },
                    userDefaults: .standard,
                    userDefaultsKey: "com.infinum.toolbox.optionSwitch.crashlytics"
                ),
                OptionSwitchItem(
                    name: "Logging",
                    setter: { AppSwitches.loggingEnabled = $0 },
                    getter: { AppSwitches.loggingEnabled },
                    userDefaults: .standard,
                    userDefaultsKey: "com.infinum.toolbox.optionSwitch.logging"
                ),
            ]
        )
    }
    
}

