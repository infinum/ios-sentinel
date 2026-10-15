//
//  ContentView.swift
//  Example-iOS
//
//  Created by Nikola Simunko on 22.09.2025..
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    private enum MenuButton {
        static let size: CGFloat = 44
        static let margin: CGFloat = 16
        static let iconSize: CGFloat = 18
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 24) {
                    Text("Shake the device or tap the button to open Sentinel")
                        .font(.title2)
                        .multilineTextAlignment(.center)

                    Button("Open Sentinel") {
                        NotificationCenter.default.post(name: .openSentinel, object: nil)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                menuButton
                    .padding(MenuButton.margin)
            }
            // The button sits in the corner on its own, so the bar would only take up space here.
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Subviews

private extension ContentView {

    var menuButton: some View {
        NavigationLink(destination: MenuView()) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: MenuButton.iconSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: MenuButton.size, height: MenuButton.size)
                .background(Color(.systemGray))
                .clipShape(Circle())
        }
        .accessibility(label: Text("Menu"))
    }
}
