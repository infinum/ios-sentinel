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
//                        PreferencesTool.Section(title: "User defaults", items: toggleItems)
                    ]
                )
            )
        }
    }

    var toggleItems: [ToggleToolItem] {
        [ToggleToolItem(title: "item", setter: { toggle = $0 }, getter: { toggle })]
    }
}

#Preview {
    SentinelAsSheet()
}
