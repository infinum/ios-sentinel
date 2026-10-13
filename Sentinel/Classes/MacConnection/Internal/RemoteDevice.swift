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

    /// The Mac keeps this many requests per device, dropping the oldest.
    static let maximumNetworkEntryCount = 2000

    let id: String
    @Published private(set) var info: RemoteDeviceInfo
    @Published private(set) var state = State.disconnected("Not connected yet.")
    /// The app's requests, oldest first.
    @Published private(set) var networkEntries: [RemoteNetworkEntry] = []
    /// Requests the device left out because the connection fell behind.
    @Published private(set) var droppedNetworkEntryCount = 0
    private(set) lazy var mockStore = RemoteAPIMockStore { [weak self] command in
        self?.connection?.send(RemoteMessage.mockCommand(command))
    }

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
        mockStore.isEditable = state == .connected
    }

    func isAttached(to connection: RemoteConnection) -> Bool {
        self.connection === connection
    }

    func detach(reason: RemoteConnection.CloseReason) {
        connection = nil
        state = .disconnected(reason.message)
        mockStore.isEditable = false
    }

    func allowPairing() {
        connection?.confirmPairing()
    }

    func rejectPairing() {
        connection?.rejectPairing()
    }

    func handle(_ message: RemoteMessage) {
        switch message {
        case .mocks(let mocks):
            mockStore.apply(mocks)
        case .mockSwitches(let switches):
            mockStore.apply(switches)
        case .networkEntry(let entry):
            record(entry)
        case .droppedNetworkEntries(let count):
            droppedNetworkEntryCount += count
        default:
            break
        }
    }

    func clearNetworkEntries() {
        networkEntries = []
        droppedNetworkEntryCount = 0
    }
}

// MARK: - Network entries

private extension RemoteDevice {

    /// A request the Mac already has is replaced in place: it started, and now it's complete. A device that
    /// reconnects sends its kept requests again, so they're replaced too rather than listed twice.
    func record(_ entry: RemoteNetworkEntry) {
        if let index = networkEntries.lastIndex(where: { $0.id == entry.id }) {
            networkEntries[index] = entry
        } else {
            networkEntries.append(entry)
            if networkEntries.count > Self.maximumNetworkEntryCount {
                networkEntries.removeFirst(networkEntries.count - Self.maximumNetworkEntryCount)
            }
        }
    }
}

#endif
