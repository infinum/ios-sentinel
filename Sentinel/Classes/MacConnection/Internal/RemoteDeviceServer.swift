//
//  RemoteDeviceServer.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(macOS)

import Foundation
import Network

/// Sentinel for Mac's side of the connection: advertises the Mac over Bonjour and keeps track of the devices
/// that connect to it. Used from the main thread.
final class RemoteDeviceServer: ObservableObject {

    enum Status: Equatable {
        case starting
        case listening(port: UInt16)
        case failed(String)
    }

    @Published private(set) var status = Status.starting
    /// Every device that connected since launch, in the order they first did.
    @Published private(set) var devices: [RemoteDevice] = []

    private let macID: String
    private let macName: String
    private let keyStore: RemotePairingKeyStore
    private var listener: NWListener?
    /// Connections that haven't said which device they are yet, kept alive until they do.
    private var connections: [ObjectIdentifier: RemoteConnection] = [:]

    // MARK: - Lifecycle

    init(
        macID: String,
        macName: String,
        keyStore: RemotePairingKeyStore
    ) {
        self.macID = macID
        self.macName = macName
        self.keyStore = keyStore
    }

    /// The server Sentinel for Mac runs, with the Mac's id kept in user defaults and the keys in the Keychain.
    static func makeDefault() -> RemoteDeviceServer {
        let idKey = "com.infinum.sentinel.mac.id"
        let macID = UserDefaults.standard.string(forKey: idKey) ?? UUID().uuidString
        UserDefaults.standard.set(macID, forKey: idKey)
        return RemoteDeviceServer(
            macID: macID,
            macName: Host.current().localizedName ?? "Mac",
            keyStore: RemoteKeychainKeyStore()
        )
    }

    func start(on port: NWEndpoint.Port = RemoteService.preferredPort) {
        guard listener == nil else { return }
        do {
            let listener = try NWListener(using: RemoteService.makeParameters(), on: port)
            listener.service = NWListener.Service(name: macName, type: RemoteService.type)
            listener.stateUpdateHandler = { [weak self] state in
                self?.handle(state, requestedPort: port)
            }
            listener.newConnectionHandler = { [weak self] connection in
                self?.accept(connection)
            }
            listener.start(queue: .main)
            self.listener = listener
        } catch {
            status = .failed(error.localizedDescription)
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
        connections.values.forEach { $0.cancel() }
        connections = [:]
    }
}

// MARK: - Listening

private extension RemoteDeviceServer {

    func handle(_ state: NWListener.State, requestedPort: NWEndpoint.Port) {
        switch state {
        case .ready:
            status = .listening(port: listener?.port?.rawValue ?? 0)
        case .failed(let error):
            listener?.cancel()
            listener = nil
            // Another app holds the preferred port, so listen on any. Devices still find the Mac through
            // Bonjour; only the Simulator, which connects to the preferred port directly, can't.
            if requestedPort != .any, case .posix(.EADDRINUSE) = error {
                start(on: .any)
            } else {
                status = .failed(error.localizedDescription)
            }
        default:
            break
        }
    }

    func accept(_ networkConnection: NWConnection) {
        let connection = RemoteConnection(
            connection: networkConnection,
            role: .mac(id: macID, name: macName),
            keyStore: keyStore
        )
        connection.onEvent = { [weak self, weak connection] event in
            guard let self, let connection else { return }
            handle(event, from: connection)
        }
        connections[ObjectIdentifier(connection)] = connection
        connection.start()
    }

    func handle(_ event: RemoteConnection.Event, from connection: RemoteConnection) {
        switch event {
        case .pairingCode(let code, let peer):
            device(for: peer)?.attach(connection, state: .pairing(code: code))
        case .connected(let peer):
            device(for: peer)?.attach(connection, state: .connected)
        case .message(let message):
            devices.first { $0.isAttached(to: connection) }?.handle(message)
        case .closed(let reason):
            connections[ObjectIdentifier(connection)] = nil
            devices.first { $0.isAttached(to: connection) }?.detach(reason: reason)
        }
    }

    /// The device the peer is, added the first time it connects. A device that connects again keeps what
    /// the Mac already received from it.
    func device(for peer: RemoteConnection.Peer) -> RemoteDevice? {
        guard let info = peer.device else { return nil }
        if let device = devices.first(where: { $0.id == info.id }) {
            device.update(info)
            return device
        }
        let device = RemoteDevice(info: info)
        devices.append(device)
        return device
    }
}

#endif
