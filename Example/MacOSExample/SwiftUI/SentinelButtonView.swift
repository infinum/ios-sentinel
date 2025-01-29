//
//  SentinelButtonView.swift
//  Example-iOS
//
//  Created by Zvonimir Medak on 29.01.2025..
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

struct SentinelButtonView: View {
    var body: some View {
        VStack {
            Text("Press the button to show Sentinel")
                .font(.headline)
            Button("Show Sentinel") {
                NotificationCenter.default.post(name: .init("SomeValue"), object: nil)
            }
        }
    }
}

#Preview {
    SentinelButtonView()
}
