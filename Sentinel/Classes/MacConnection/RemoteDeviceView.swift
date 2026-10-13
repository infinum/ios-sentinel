//
//  RemoteDeviceView.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(macOS)

import SwiftUI

/// One device in Sentinel Companion: the pairing prompt while it pairs, and its tools once it's connected.
struct RemoteDeviceView: View {

    @ObservedObject var device: RemoteDevice

    var body: some View {
        switch device.state {
        case .pairing(let code):
            pairing(code: code)
        case .connected, .disconnected:
            VStack(spacing: 0) {
                if case .disconnected(let message) = device.state {
                    banner(message)
                }
                details
            }
        }
    }
}

// MARK: - Pairing

private extension RemoteDeviceView {

    func pairing(code: String) -> some View {
        VStack(spacing: 16) {
            Text("\(device.info.appName) on \(device.info.deviceName) wants to connect")
                .font(.subtitle1Bold)
            Text(code.formattedPairingCode)
                .font(.system(size: 40, weight: .semibold, design: .monospaced))
                .textSelection(.enabled)
            Text("Allow it only if the device shows the same code.")
                .foregroundColor(.secondary)
            HStack {
                Button("Deny", role: .cancel, action: device.rejectPairing)
                Button("Allow", action: device.allowPairing)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Details

private extension RemoteDeviceView {

    var details: some View {
        TabView {
            RemoteNetworkView(device: device)
                .tabItem { Text("Network") }
            APIMockingView(title: device.info.appName, store: device.mockStore)
                .tabItem { Text("API Mocking") }
            info
                .tabItem { Text("Device") }
        }
        .padding(.top, 8)
        .navigationTitle(device.info.appName)
    }

    var info: some View {
        Form {
            LabeledContent("App", value: device.info.appName)
            LabeledContent("Version", value: device.info.appVersion)
            LabeledContent("Bundle ID", value: device.info.bundleID)
            LabeledContent("Device", value: device.info.deviceName)
            LabeledContent("System", value: device.info.systemVersion)
        }
        .formStyle(.grouped)
    }

    func banner(_ message: String) -> some View {
        Text(message)
            .font(.caption1Regular)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.15))
    }
}

#endif
