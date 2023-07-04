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
                CustomLocationTool(),
                createJSONMockTool(),
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
    
    var optionSwitchItems: [OptionSwitchItem] {
       [
        OptionSwitchItem(
            name: "Analytics",
            setter: { AppSwitches.analyticsEnabled = $0 },
            getter: { AppSwitches.analyticsEnabled },
            userDefaults: .standard,
            userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
        ),
        OptionSwitchItem(
            name: "Crashlytics",
            setter: { AppSwitches.crashlyticsEnabled = $0 },
            getter: { AppSwitches.crashlyticsEnabled },
            userDefaults: .standard,
            userDefaultsKey: "com.infinum.sentinel.optionSwitch.crashlytics"
        ),
        OptionSwitchItem(
            name: "Logging",
            setter: { AppSwitches.loggingEnabled = $0 },
            getter: { AppSwitches.loggingEnabled },
            userDefaults: .standard,
            userDefaultsKey: "com.infinum.sentinel.optionSwitch.logging"
        ),
       ]

    }
    
    func createJSONMockTool() -> JSONMockTool {
        let folderAFiles = ["AA", "AB", "AC"]
        let folderBFiles = ["BA", "BB", "BC"]

        let folders = [
            JSONMockFolder(jsonNames: folderAFiles, folderName: "Folder A"),
            JSONMockFolder(
                jsonNames: folderBFiles,
                folders: [JSONMockFolder(jsonNames: ["Nested jos jednom"], folderName: "Nested in Folder B")],
                folderName: "Folder B"
            )
        ]
        
        let mockModel = JSONMockModel(folders: folders) { jsons in
            print("sfdgds")
            print(jsons.values)
        }
//        let usedJSONS = mockModel.usedJSONs()
//        print("111!!!\n\(usedJSONS.joined(separator: ", "))")
        return JSONMockTool(mockModel: mockModel)
    }
    
}

