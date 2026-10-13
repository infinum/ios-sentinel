//
//  SentinelMacTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(macOS)
import CryptoKit
import Foundation
import Network
import Testing
@testable import Sentinel

@Suite("Sentinel for Mac")
struct SentinelMacTests {

    // MARK: - Device

    @Test("A finished request replaces the one that started, in place")
    func replacesEntry() {
        let device = RemoteDevice(info: RemoteLoopback.device)
        var started = entry()
        let other = entry()
        device.handle(.networkEntry(started))
        device.handle(.networkEntry(other))

        started.duration = 0.3
        device.handle(.networkEntry(started))

        #expect(device.networkEntries == [started, other])
    }

    @Test("Only the latest requests are kept")
    func cap() {
        let device = RemoteDevice(info: RemoteLoopback.device)
        let first = entry()
        device.handle(.networkEntry(first))

        for _ in 0..<RemoteDevice.maximumNetworkEntryCount {
            device.handle(.networkEntry(entry()))
        }

        #expect(device.networkEntries.count == RemoteDevice.maximumNetworkEntryCount)
        #expect(!device.networkEntries.contains(first))
    }

    @Test("Left-out requests add up, and clearing forgets them with the rest")
    func droppedAndCleared() {
        let device = RemoteDevice(info: RemoteLoopback.device)
        device.handle(.networkEntry(entry()))
        device.handle(.droppedNetworkEntries(2))
        device.handle(.droppedNetworkEntries(3))

        #expect(device.droppedNetworkEntryCount == 5)

        device.clearNetworkEntries()

        #expect(device.networkEntries.isEmpty)
        #expect(device.droppedNetworkEntryCount == 0)
    }

    @Test("Mocks can be changed only while the device is connected")
    func editableWhileConnected() {
        let device = RemoteDevice(info: RemoteLoopback.device)
        let connection = idleConnection()

        device.attach(connection, state: .pairing(code: "123456"))
        #expect(!device.mockStore.isEditable)

        device.attach(connection, state: .connected)
        #expect(device.mockStore.isEditable)

        device.detach(reason: .timedOut)
        #expect(!device.mockStore.isEditable)
        #expect(device.state == .disconnected(RemoteConnection.CloseReason.timedOut.message))
    }

    @Test("The device's mocks and switches reach the Mac's copy")
    func mocks() {
        let device = RemoteDevice(info: RemoteLoopback.device)
        let mock = APIMock(name: "Products", url: .wildcard("/products"), body: .json("[]"))

        device.handle(.mocks([RemoteMock(mock: mock, isLocal: false)]))
        device.handle(.mockSwitches(RemoteMockSwitches(isMockingEnabled: true, enabledIDs: [mock.id])))

        #expect(device.mockStore.appMocks == [mock])
        #expect(device.mockStore.activeMocks == [mock])
    }

    // MARK: - Server

    @Test("A device that connects again is the same device, keeping what the Mac received")
    func reconnectingDevice() async throws {
        let server = makeServer()
        let port = try await listen(server)
        let deviceStore = InMemoryPairingKeyStore()

        let first = connectDevice(to: port, keyStore: deviceStore)
        let device = try await waitForDevice(on: server) { $0.pairingCode != nil }
        device.allowPairing()
        first.connection.confirmPairing()
        _ = try await first.events.next { $0.isConnected }
        device.handle(.networkEntry(entry()))
        first.connection.cancel()

        let second = connectDevice(to: port, keyStore: deviceStore)
        _ = try await second.events.next { $0.isConnected }

        #expect(server.devices.count == 1)
        #expect(server.devices.first === device)
        #expect(device.state == .connected)
        #expect(device.networkEntries.count == 1)
        server.stop()
    }

    @Test("When the preferred port is taken, the Mac listens on another one")
    func portTaken() async throws {
        let blocker = try NWListener(using: RemoteService.makeParameters(), on: .any)
        blocker.newConnectionHandler = { $0.cancel() }
        blocker.start(queue: .main)
        let takenPort = try await waitForPort(of: blocker)
        let server = makeServer()

        server.start(on: takenPort)
        let port = try await listen(server, startingOn: nil)

        #expect(port != takenPort.rawValue)
        server.stop()
        blocker.cancel()
    }

    // MARK: - Keychain

    @Test("The Keychain keeps a key per device until it's removed")
    func keychain() {
        let store = RemoteKeychainKeyStore(service: "com.infinum.sentinel.tests.\(UUID().uuidString)")
        let key = SymmetricKey(size: .bits256)
        defer { store.removeKey(forPeer: "device") }

        store.save(key, forPeer: "device")
        #expect(store.key(forPeer: "device")?.data == key.data)

        let newKey = SymmetricKey(size: .bits256)
        store.save(newKey, forPeer: "device")
        #expect(store.key(forPeer: "device")?.data == newKey.data)

        store.removeKey(forPeer: "device")
        #expect(store.key(forPeer: "device") == nil)
    }

    // MARK: - Helpers

    private func entry() -> RemoteNetworkEntry {
        RemoteNetworkEntry(
            id: UUID(),
            createdAt: Date(),
            method: "GET",
            url: "https://example.com/products",
            requestHeaders: [:],
            isMocked: false
        )
    }

    /// A connection that's never started, for attaching to a device.
    private func idleConnection() -> RemoteConnection {
        RemoteConnection(
            connection: NWConnection(host: "127.0.0.1", port: 9, using: .tcp),
            role: .mac(id: "mac", name: "Mac"),
            keyStore: InMemoryPairingKeyStore()
        )
    }

    private func makeServer() -> RemoteDeviceServer {
        RemoteDeviceServer(macID: RemoteLoopback.macID, macName: "Test Mac", keyStore: InMemoryPairingKeyStore())
    }

    /// Starts the server on any port, unless it was started already, and waits until it listens.
    private func listen(_ server: RemoteDeviceServer, startingOn port: NWEndpoint.Port? = .any) async throws -> UInt16 {
        if let port {
            server.start(on: port)
        }
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            if case .listening(let port) = await MainActor.run(body: { server.status }) {
                return port
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        throw RemoteEventRecorder.Timeout()
    }

    private func waitForPort(of listener: NWListener) async throws -> NWEndpoint.Port {
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            if let port = listener.port, port != .any {
                return port
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        throw RemoteEventRecorder.Timeout()
    }

    private func connectDevice(
        to port: UInt16,
        keyStore: InMemoryPairingKeyStore
    ) -> (connection: RemoteConnection, events: RemoteEventRecorder) {
        let events = RemoteEventRecorder()
        let connection = RemoteConnection(
            connection: NWConnection(
                host: "127.0.0.1",
                port: NWEndpoint.Port(rawValue: port)!,
                using: RemoteService.makeParameters()
            ),
            role: .device(RemoteLoopback.device, pairedMacIDs: keyStore.pairedPeerIDs),
            keyStore: keyStore
        )
        connection.onEvent = { events.record($0) }
        connection.start()
        return (connection, events)
    }

    private func waitForDevice(
        on server: RemoteDeviceServer,
        where matches: @escaping (RemoteDevice) -> Bool
    ) async throws -> RemoteDevice {
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            let device = await MainActor.run { server.devices.first(where: matches) }
            if let device {
                return device
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        throw RemoteEventRecorder.Timeout()
    }
}

private extension RemoteDevice {

    var pairingCode: String? {
        if case .pairing(let code) = state { return code }
        return nil
    }
}
#endif
