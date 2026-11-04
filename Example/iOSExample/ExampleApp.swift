//
//  ExampleApp.swift
//  Example-iOS
//
//  Created by Nikola Simunko on 22.09.2025..
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

@main
struct ExampleApp: App {

    // Sentinel is set up from the app delegate, and `Triggers.shake` swizzles `UIApplication`,
    // so the delegate is kept around under the SwiftUI lifecycle.
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
