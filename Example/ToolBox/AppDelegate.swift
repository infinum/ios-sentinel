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

private extension AppDelegate {
    
    func setupToolBox() {
        let configuration = ToolBox.Configuration(
            trigger: Triggers.shake,
            tools: [
                GeneralInfoTool(),
                UserDefaultsTool(),
                baseUrlTool,
                LocationMockTool(),
//                BugsnatchTool(triggerActionConfig: EmailConfig()),
//                LoggieTool(),
//                AnalyticsCollectorTool(),
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
    
}

