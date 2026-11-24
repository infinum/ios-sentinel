//
//  ContentView.swift
//  Example-iOS
//
//  Created by Nikola Simunko on 22.09.2025..
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

                    // The UI tests get their own button, which goes through the shake trigger.
                    if LaunchEnvironment.isUITesting {
                        openSentinelButton
                        crashButton
                    } else {
                        Button("Open Sentinel") {
                            NotificationCenter.default.post(name: .openSentinel, object: nil)
                        }
                        .buttonStyle(.borderedProminent)
                    }
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

    /// UI tests can't shake the simulator, so they send the same shake event through this button.
    var openSentinelButton: some View {
        Button("Open Sentinel") {
            UIApplication.shared.motionEnded(.motionShake, with: nil)
        }
        .accessibilityIdentifier("example.openSentinel")
    }

    /// Crashes the app so the UI tests have a real crash for the Crash Detection tool to list.
    var crashButton: some View {
        Button("Crash") {
            NSException(
                name: NSExceptionName("SentinelUITestCrash"),
                reason: "Raised by the UI tests",
                userInfo: nil
            ).raise()
        }
        .accessibilityIdentifier("example.crash")
    }
}
