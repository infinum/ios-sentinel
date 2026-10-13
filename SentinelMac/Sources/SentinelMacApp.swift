//
//  SentinelMacApp.swift
//  SentinelMac
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI
@_spi(SentinelMac) import Sentinel

@main
struct SentinelMacApp: App {

    var body: some Scene {
        // A single window, as each one would listen for devices on its own.
        Window("Sentinel", id: "main") {
            SentinelMacView()
                .frame(minWidth: 860, minHeight: 520)
        }
    }
}
