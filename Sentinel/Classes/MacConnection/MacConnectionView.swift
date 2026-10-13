//
//  MacConnectionView.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(iOS)

import SwiftUI

struct MacConnectionView: View {

    let title: String

    // The session is a singleton, so observing it directly survives `SentinelListView` rebuilding this view.
    @ObservedObject private var session = DeviceSession.shared

    var body: some View {
        List {
            Section(footer: Text("Sentinel Companion shows the app's network traffic live and controls its API mocks.")) {
                Toggle(
                    "Connect to Mac",
                    isOn: Binding(
                        get: { session.isEnabled },
                        set: { session.setEnabled($0) }
                    )
                )
                .accessibilityIdentifier(AccessibilityIdentifier.macConnectionSwitch)
            }

            let missingEntries = DeviceSession.missingInfoPlistEntries
            if !missingEntries.isEmpty {
                Section(header: Text("Info.plist")) {
                    Text("Finding Macs needs local network access. Add to the app's Info.plist: \(missingEntries.joined(separator: ", ")).")
                        .font(.caption1Regular)
                        .foregroundColor(.red)
                }
            }

            if session.isEnabled {
                Section(header: Text("Status")) {
                    statusView
                }

                Section(header: Text("Macs"), footer: Text("Open Sentinel Companion on a Mac nearby to see it here.")) {
                    ForEach(session.macs) { mac in
                        Button {
                            session.connect(to: mac)
                        } label: {
                            HStack {
                                Text(mac.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if isConnected(to: mac) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .accessibilityIdentifier(AccessibilityIdentifier.row(mac.name))
                    }
                }
            }
        }
        .pushedListTopMargin(isPushed: true)
        .navigationTitle(title)
    }
}

// MARK: - Status

private extension MacConnectionView {

    @ViewBuilder
    var statusView: some View {
        switch session.status {
        case .off:
            Text("Off")
        case .searching:
            Text("Looking for Macs…")
        case .connecting(let macName):
            Text("Connecting to \(macName)…")
        case .connected(let macName):
            Text("Connected to \(macName)")
        case .failed(let message):
            Text(message)
                .foregroundColor(.red)
        case .pairing(let code, let macName):
            VStack(alignment: .leading, spacing: 12) {
                Text("Pairing with \(macName)")
                    .font(.body1Bold)
                Text(code.formattedPairingCode)
                    .font(.system(size: 34, weight: .semibold, design: .monospaced))
                Text("Check that the Mac shows the same code, then confirm here and allow the connection on the Mac.")
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)
                HStack {
                    Button("Cancel", role: .cancel, action: session.rejectPairing)
                    Spacer()
                    Button("Codes match", action: session.confirmPairing)
                        .accessibilityIdentifier(AccessibilityIdentifier.macConnectionConfirmButton)
                }
                // Two buttons in one row would otherwise both fire on any tap in the row.
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 4)
        }
    }

    func isConnected(to mac: DeviceSession.DiscoveredMac) -> Bool {
        guard case .connected = session.status else { return false }
        return session.selectedMac == mac
    }
}

#endif
