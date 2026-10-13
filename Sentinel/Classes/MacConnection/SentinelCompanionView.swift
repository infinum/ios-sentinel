//
//  SentinelCompanionView.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(macOS)

import SwiftUI

/// The window of Sentinel Companion: the devices that connected to this Mac and, for the selected one, its
/// network traffic and API mocks.
///
/// Only Sentinel Companion uses it, so it's left out of the public API: import it with
/// `@_spi(SentinelCompanion) import Sentinel`. Creating it starts listening for devices.
@_spi(SentinelCompanion)
public struct SentinelCompanionView: View {

    @StateObject private var server = RemoteDeviceServer.makeDefault()
    @State private var selectedDeviceID: String?

    public init() {}

    public var body: some View {
        NavigationSplitView {
            List(selection: $selectedDeviceID) {
                Section("Devices") {
                    ForEach(server.devices) { device in
                        RemoteDeviceRow(device: device)
                            .tag(device.id)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Text(statusText)
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } detail: {
            if let device = server.devices.first(where: { $0.id == selectedDeviceID }) {
                RemoteDeviceView(device: device)
            } else {
                placeholder
            }
        }
        .onAppear {
            server.start()
        }
        .onChange(of: server.devices.map(\.id)) { ids in
            if selectedDeviceID == nil {
                selectedDeviceID = ids.first
            }
        }
    }
}

// MARK: - Helpers

private extension SentinelCompanionView {

    var placeholder: some View {
        VStack(spacing: 8) {
            Text("No device selected")
                .font(.subtitle1Bold)
            Text("Add MacConnectionTool to an app's Sentinel tools, open it on the device, and switch on the connection. This Mac shows up in its list.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .frame(maxWidth: 360)
        }
        .padding()
    }

    var statusText: String {
        switch server.status {
        case .starting:
            return "Starting…"
        case .listening(let port) where port == RemoteService.preferredPort.rawValue:
            return "Waiting for devices."
        case .listening:
            return "Waiting for devices. Another app uses port \(RemoteService.preferredPort.rawValue), so the iOS Simulator can't connect."
        case .failed(let message):
            return "Can't wait for devices: \(message)"
        }
    }
}

// MARK: - Row

private struct RemoteDeviceRow: View {

    @ObservedObject var device: RemoteDevice

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(device.info.appName)
                    .font(.body1Bold)
                Text(device.info.deviceName)
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var statusColor: Color {
        switch device.state {
        case .connected: return .green
        case .pairing: return .orange
        case .disconnected: return .gray
        }
    }
}

#endif
