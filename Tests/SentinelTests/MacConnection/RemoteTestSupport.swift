//
//  RemoteTestSupport.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import CryptoKit
import Foundation
import Network
@testable import Sentinel

final class InMemoryPairingKeyStore: RemotePairingKeyStore {

    private let lock = NSLock()
    private var keys: [String: SymmetricKey] = [:]

    var pairedPeerIDs: [String] {
        lock.lock()
        defer { lock.unlock() }
        return keys.keys.sorted()
    }

    func key(forPeer id: String) -> SymmetricKey? {
        lock.lock()
        defer { lock.unlock() }
        return keys[id]
    }

    func save(_ key: SymmetricKey, forPeer id: String) {
        lock.lock()
        keys[id] = key
        lock.unlock()
    }

    func removeKey(forPeer id: String) {
        lock.lock()
        keys[id] = nil
        lock.unlock()
    }
}

/// Collects a connection's events, which arrive on the main queue, for a test to take one at a time.
final class RemoteEventRecorder {

    struct Timeout: Error {}

    private let lock = NSLock()
    private var events: [RemoteConnection.Event] = []

    func record(_ event: RemoteConnection.Event) {
        lock.lock()
        events.append(event)
        lock.unlock()
    }

    func next(within seconds: TimeInterval = 5) async throws -> RemoteConnection.Event {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            if let event = takeFirst() {
                return event
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        throw Timeout()
    }

    /// Skips events until one matches.
    func next(
        within seconds: TimeInterval = 5,
        where matches: (RemoteConnection.Event) -> Bool
    ) async throws -> RemoteConnection.Event {
        let deadline = Date().addingTimeInterval(seconds)
        while true {
            let event = try await next(within: max(0, deadline.timeIntervalSinceNow))
            if matches(event) {
                return event
            }
        }
    }

    private func takeFirst() -> RemoteConnection.Event? {
        lock.lock()
        defer { lock.unlock() }
        return events.isEmpty ? nil : events.removeFirst()
    }
}

/// A Mac and a device connected over localhost, each with its own key store.
final class RemoteLoopback {

    static let macID = "mac-id"
    static let device = RemoteDeviceInfo(
        id: "device-id",
        deviceName: "Test iPhone",
        systemVersion: "iOS 26.0",
        appName: "Test App",
        bundleID: "com.infinum.test",
        appVersion: "1.0"
    )

    let macStore = InMemoryPairingKeyStore()
    let deviceStore = InMemoryPairingKeyStore()
    let macEvents = RemoteEventRecorder()
    let deviceEvents = RemoteEventRecorder()

    // Set on the main queue, where the listener runs.
    private(set) var macConnection: RemoteConnection?
    private(set) var deviceConnection: RemoteConnection?
    private let listener: NWListener

    init() throws {
        listener = try NWListener(using: RemoteService.makeParameters(), on: .any)
    }

    deinit {
        stop()
    }

    func start() async throws {
        listener.newConnectionHandler = { [weak self] networkConnection in
            guard let self else { return }
            let connection = RemoteConnection(
                connection: networkConnection,
                role: .mac(id: Self.macID, name: "Test Mac"),
                keyStore: macStore
            )
            connection.onEvent = { [macEvents] event in
                macEvents.record(event)
            }
            macConnection = connection
            connection.start()
        }
        listener.start(queue: .main)
        let deadline = Date().addingTimeInterval(5)
        while listener.port == nil || listener.port == NWEndpoint.Port.any {
            guard Date() < deadline else { throw RemoteEventRecorder.Timeout() }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    func connectDevice() {
        guard let port = listener.port else { return }
        let connection = RemoteConnection(
            connection: NWConnection(
                host: NWEndpoint.Host("127.0.0.1"),
                port: port,
                using: RemoteService.makeParameters()
            ),
            role: .device(Self.device, pairedMacIDs: deviceStore.pairedPeerIDs),
            keyStore: deviceStore
        )
        connection.onEvent = { [deviceEvents] event in
            deviceEvents.record(event)
        }
        deviceConnection = connection
        connection.start()
    }

    /// Pairs the two sides from scratch and waits until both are connected.
    func pair() async throws {
        connectDevice()
        _ = try await macEvents.next { $0.isPairingCode }
        _ = try await deviceEvents.next { $0.isPairingCode }
        macConnection?.confirmPairing()
        deviceConnection?.confirmPairing()
        _ = try await macEvents.next { $0.isConnected }
        _ = try await deviceEvents.next { $0.isConnected }
    }

    func stop() {
        listener.cancel()
        macConnection?.cancel()
        deviceConnection?.cancel()
    }
}

extension SymmetricKey {

    var data: Data {
        withUnsafeBytes { Data($0) }
    }
}

extension RemoteConnection.Event {

    var isPairingCode: Bool {
        if case .pairingCode = self { return true }
        return false
    }

    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }

    var isClosed: Bool {
        if case .closed = self { return true }
        return false
    }

    var pairingCode: String? {
        if case .pairingCode(let code, _) = self { return code }
        return nil
    }
}
