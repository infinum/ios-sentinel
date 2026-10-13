//
//  RemoteDevice.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(macOS)

import Foundation

/// An app on a device, as Sentinel for Mac sees it. Used from the main thread.
final class RemoteDevice: ObservableObject, Identifiable {

    enum State: Equatable {
        /// A new pairing, waiting for the user to compare the code with the one on the device.
        case pairing(code: String)
        case connected
        case disconnected(String)
    }

    let id: String
    @Published private(set) var info: RemoteDeviceInfo
    @Published private(set) var state = State.disconnected("Not connected yet.")

    private var connection: RemoteConnection?

    // MARK: - Lifecycle

    init(info: RemoteDeviceInfo) {
        id = info.id
        self.info = info
    }

    func update(_ info: RemoteDeviceInfo) {
        if self.info != info {
            self.info = info
        }
    }
}

// MARK: - Connection

extension RemoteDevice {

    func attach(_ connection: RemoteConnection, state: State) {
        // The device came back before the Mac noticed its old connection was gone.
        if let current = self.connection, current !== connection {
            current.cancel()
        }
        self.connection = connection
        self.state = state
    }

    func isAttached(to connection: RemoteConnection) -> Bool {
        self.connection === connection
    }

    func detach(reason: RemoteConnection.CloseReason) {
        connection = nil
        state = .disconnected(reason.message)
    }

    func allowPairing() {
        connection?.confirmPairing()
    }

    func rejectPairing() {
        connection?.rejectPairing()
    }

    func handle(_ message: RemoteMessage) {}
}

#endif
