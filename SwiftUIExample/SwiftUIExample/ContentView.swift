//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by Zvonimir Medak on 20.01.2025..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(macOS)
        VStack {
            Text("Press the button to show Sentinel")
                .font(.headline)
            Button("Show Sentinel") {
                NotificationCenter.default.post(name: .init("SomeValue"), object: nil)
            }
        }
        #else
        VStack {
            Text("Shake the device to show Sentinel")
                .font(.headline)
        }
        #endif
    }
}

#Preview {
    ContentView()
}
