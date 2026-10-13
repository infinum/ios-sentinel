//
//  SentinelCompanionApp.swift
//  SentinelCompanion
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI
@_spi(SentinelCompanion) import Sentinel

@main
struct SentinelCompanionApp: App {

    var body: some Scene {
        // A single window, as each one would listen for devices on its own.
        Window("Sentinel Companion", id: "main") {
            SentinelCompanionView()
                .frame(minWidth: 860, minHeight: 520)
        }
    }
}
