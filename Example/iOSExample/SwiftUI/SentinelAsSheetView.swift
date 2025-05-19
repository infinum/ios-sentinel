//
//  SentinelAsSheetView.swift
//  Example-iOS
//
//  Created by Zvonimir Medak on 29.01.2025..
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI
import Sentinel

struct SentinelAsSheet: View {

    @AppStorage("editText") var editText: String = "Word"
    @AppStorage("toggle") var toggle: Bool = false
    @State var showSentinel = false

    var body: some View {
        VStack {
            Text("Press the button to show Sentinel")
                .font(.headline)
            Button("Show Sentinel") {
                showSentinel.toggle()
            }
        }
        .sheet(isPresented: $showSentinel) {
            Sentinel.createSentinelView(
                with: Sentinel.Configuration(
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
    }

    var toggleItems: [any PreferenceItem] {
        [
            ToggleToolItem(
                title: "Analytics",
                userDefaults: .standard,
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
            ),
            ToggleToolItem(
                title: "Crashlytics",
                setter: { AppPreferences.crashlyticsEnabled = $0 },
                getter: { AppPreferences.crashlyticsEnabled }
            ),
            ToggleToolItem(
                title: "Logging",
                userDefaults: .standard,
                userDefaultsKey: "com.infinum.sentinel.optionSwitch.logging"
            ),
            PreferencesTextItem(title: "name", userDefaultsKey: "com.infinum.sentinel.name"),
            PreferencesIntItem(title: "some number", userDefaultsKey: "com.inifnum.sentinel.number"),
            PreferencesPickerItem(
                title: "Picker values",
                values: SomePickerValue.allCases,
                setter: { value in AppPreferences.pickerValue = value as! SomePickerValue },
                getter: { AppPreferences.pickerValue })
        ]
    }
}

#Preview {
    SentinelAsSheet()
}
