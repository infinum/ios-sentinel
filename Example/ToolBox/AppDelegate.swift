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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupToolBox()
        return true
    }
}

extension AppDelegate {
    
    func setupToolBox() {
        let configuration = ToolBox.Configuration(
            trigger: Triggers.shake,
            tools: [
                GeneralInfoTool(),
                UserDefaultsTool(),
//                BugsnatchTool(triggerActionConfig: EmailConfig()),
//                LoggieTool(),
            ]
        )
        
        ToolBox.shared.setup(with: configuration)
    }
    
}

