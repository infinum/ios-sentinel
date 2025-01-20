//
//  SwiftUIExampleApp.swift
//  SwiftUIExample
//
//  Created by Zvonimir Medak on 20.01.2025..
//

import SwiftUI
import Sentinel

@main
struct SwiftUIExampleApp: App {

    @AppStorage("editText") var editText: String = "Word"
    @AppStorage("toggle") var toggle: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Sentinel.shared.setup(
                        with: Sentinel.Configuration(
                            trigger: trigger,
                            tools: [
                                UserDefaultsTool(),
                                TextEditingTool(
                                    name: "TextEditingTool",
                                    setter: { editText = $0 },
                                    getter: { editText })
                            ],
                            preferences: [
                                PreferencesTool.Section(title: "User defaults", items: toggleItems)
                            ]
                        )
                    )
                }
            // Uncomment to check out how to show Sentinel by using the Sheet modifier
//            SentinelAsSheet()
        }
    }

    var toggleItems: [ToggleToolItem] {
        [ToggleToolItem(title: "item", setter: { toggle = $0 }, getter: { toggle })]
    }

    var trigger: Trigger {
        #if os(macOS)
        NotificationTrigger(notificationName: .init("SomeValue"))
        #else
        ShakeTrigger()
        #endif
    }
}
