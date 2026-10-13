//
//  RemoteConnection.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import CryptoKit
import Foundation
import Network

/// One connection between Sentinel in an app and Sentinel for Mac.
///
/// It frames the TCP stream, runs the handshake, seals every later frame, and gives up on the connection when
/// the other side goes quiet. Events arrive on the main queue; everything else runs on the connection's queue.
final class RemoteConnection {

    enum Role {
        case device(RemoteDeviceInfo)
        case mac(id: String, name: String)
    }

    struct Peer: Equatable {
        let id: String
        let name: String
        /// The app and the device it runs on, when the other side is a device.
        let device: RemoteDeviceInfo?
    }

    enum Event: Equatable {
        /// A new pairing waits for the user to compare this code with the one on the other side.
        case pairingCode(String, Peer)
        /// Both sides accepted each other, and messages flow.
        case connected(Peer)
        case message(RemoteMessage)
        case closed(CloseReason)
    }

    enum CloseReason: Equatable {
        case cancelled
        /// A user turned the pairing down, on either side.
        case rejected
        case unsupportedVersion
        /// The other side sealed its frames with another key.
        case authenticationFailed
        case timedOut
        case failed(String)
    }

    /// How long the other side may stay quiet before the connection is given up.
    static let timeout: TimeInterval = 15
    static let pingInterval: TimeInterval = 5

    /// Set before ``start()``.
    var onEvent: ((Event) -> Void)?

    private enum State {
        case starting
        case awaitingClientHello
        case awaitingServerHello(nonce: Data, privateKey: Curve25519.KeyAgreement.PrivateKey)
        case securing(Session)
        case connected(Peer)
        case closed
    }

    private struct Session {
        let peer: Peer
        let pairingKey: SymmetricKey
        let isNewPairing: Bool
        var isLocallyReady = false
        var isRemotelyReady = false
    }

    private let connection: NWConnection
    private let role: Role
    private let keyStore: RemotePairingKeyStore
    private let queue = DispatchQueue(label: "com.infinum.sentinel.remote-connection")

    // Only used on `queue`.
    private var state = State.starting
    private var decoder = RemoteFrameDecoder()
    private var cipher: RemoteFrameCipher?
    private var timer: DispatchSourceTimer?
    private var lastReceived = Date()
    private var backlog: RemoteBacklog

    // MARK: - Lifecycle

    init(
        connection: NWConnection,
        role: Role,
        keyStore: RemotePairingKeyStore,
        backlogLimit: Int = RemoteBacklog.defaultLimit
    ) {
        self.connection = connection
        self.role = role
        self.keyStore = keyStore
        backlog = RemoteBacklog(limit: backlogLimit)
    }

    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            self?.handle(state)
        }
        connection.start(queue: queue)
        receive()
    }

    func cancel() {
        queue.async { [self] in
            close(.cancelled)
        }
    }
}

// MARK: - Close reason

extension RemoteConnection.CloseReason {

    /// Why the connection ended, for either side to show.
    var message: String {
        switch self {
        case .cancelled:
            return "Disconnected."
        case .rejected:
            return "The pairing was turned down."
        case .unsupportedVersion:
            return "Sentinel in the app and Sentinel for Mac speak different versions. Update the older one."
        case .authenticationFailed:
            return "The pairing no longer matches. Connect again to pair anew."
        case .timedOut:
            return "The connection timed out."
        case .failed(let message):
            return message
        }
    }
}

// MARK: - Pairing

extension RemoteConnection {

    /// The user confirmed that both sides show the same code.
    func confirmPairing() {
        queue.async { [self] in
            markLocallyReady()
        }
    }

    func rejectPairing() {
        queue.async { [self] in
            guard case .securing = state else { return }
            // Closed once the answer is out, so the other side can say why.
            sendSealed(.rejected) { [self] in
                close(.rejected)
            }
        }
    }
}

// MARK: - Sending

extension RemoteConnection {

    /// Sends a message once both sides are connected; before that, it's dropped.
    ///
    /// A droppable message is also left out while the network falls behind, so the app's memory doesn't grow
    /// with a backlog the Mac can't take. The other side is told how many were left out.
    func send(_ message: RemoteMessage, isDroppable: Bool = false) {
        queue.async { [self] in
            guard case .connected = state else { return }
            backlog.messages(for: message, isDroppable: isDroppable).forEach { sendSealed($0) }
        }
    }
}

// MARK: - Connection state

private extension RemoteConnection {

    var isDevice: Bool {
        if case .device = role { return true }
        return false
    }

    var isClosed: Bool {
        if case .closed = state { return true }
        return false
    }

    func handle(_ connectionState: NWConnection.State) {
        switch connectionState {
        case .ready:
            lastReceived = Date()
            startTimer()
            switch role {
            case .device(let device):
                sendClientHello(for: device)
            case .mac:
                state = .awaitingClientHello
            }
        case .waiting(let error), .failed(let error):
            close(.failed(error.localizedDescription))
        case .cancelled:
            close(.cancelled)
        default:
            break
        }
    }

    func close(_ reason: CloseReason) {
        guard !isClosed else { return }
        state = .closed
        timer?.cancel()
        timer = nil
        cipher = nil
        connection.stateUpdateHandler = nil
        connection.cancel()
        emit(.closed(reason))
    }

    func emit(_ event: Event) {
        DispatchQueue.main.async { [self] in
            onEvent?(event)
        }
    }

    func startTimer() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + Self.pingInterval, repeating: Self.pingInterval)
        timer.setEventHandler { [weak self] in
            self?.checkLiveness()
        }
        timer.resume()
        self.timer = timer
    }

    /// The device pings and the Mac answers, so either side notices when the other goes quiet.
    func checkLiveness() {
        guard Date().timeIntervalSince(lastReceived) <= Self.timeout else {
            close(.timedOut)
            return
        }
        if isDevice, cipher != nil {
            sendSealed(.ping)
        }
    }
}

// MARK: - Receiving

private extension RemoteConnection {

    func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            if let data, !data.isEmpty {
                handle(received: data)
            }
            if let error {
                close(.failed(error.localizedDescription))
            } else if isComplete {
                close(.failed("The other side closed the connection."))
            } else if !isClosed {
                receive()
            }
        }
    }

    func handle(received data: Data) {
        lastReceived = Date()
        do {
            for frame in try decoder.append(data) {
                guard !isClosed else { return }
                try handle(frame: frame)
            }
        } catch {
            close(.failed("\(error)"))
        }
    }

    func handle(frame: Data) throws {
        switch state {
        case .starting, .closed:
            return
        case .awaitingClientHello:
            try handle(try JSONDecoder().decode(RemoteClientHello.self, from: frame))
        case .awaitingServerHello(let nonce, let privateKey):
            try handle(
                try JSONDecoder().decode(RemoteServerHello.self, from: frame),
                nonce: nonce,
                privateKey: privateKey
            )
        case .securing, .connected:
            let plaintext: Data?
            do {
                plaintext = try cipher?.open(frame)
            } catch {
                failAuthentication()
                return
            }
            // A newer peer may send messages this version doesn't know, which are skipped.
            guard let plaintext, let message = try? JSONDecoder().decode(RemoteMessage.self, from: plaintext) else {
                return
            }
            handle(message)
        }
    }

    func handle(_ message: RemoteMessage) {
        switch message {
        case .ping:
            sendSealed(.pong)
        case .pong:
            break
        case .rejected:
            close(.rejected)
        case .ready:
            guard case .securing(var session) = state else { return }
            session.isRemotelyReady = true
            state = .securing(session)
            connectIfBothReady()
        default:
            guard case .connected = state else { return }
            emit(.message(message))
        }
    }

    /// A resumed pairing whose first frame doesn't open means the two sides hold different keys. Forgetting
    /// this side's key makes the next connection pair again instead of failing the same way.
    func failAuthentication() {
        if case .securing(let session) = state, !session.isNewPairing {
            keyStore.removeKey(forPeer: session.peer.id)
        }
        close(.authenticationFailed)
    }
}

// MARK: - Handshake

private extension RemoteConnection {

    func sendClientHello(for device: RemoteDeviceInfo) {
        let nonce = RemotePairing.makeNonce()
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        state = .awaitingServerHello(nonce: nonce, privateKey: privateKey)
        sendPlain(
            RemoteClientHello(
                protocolVersion: RemoteHandshake.protocolVersion,
                device: device,
                pairedMacIDs: keyStore.pairedPeerIDs,
                nonce: nonce,
                pairingPublicKey: privateKey.publicKey.rawRepresentation
            )
        )
    }

    /// The Mac's side: resume the pairing when both sides have a key, or start a new one.
    func handle(_ hello: RemoteClientHello) throws {
        guard case .mac(let macID, let macName) = role else { return }
        let nonce = RemotePairing.makeNonce()
        let peer = Peer(id: hello.device.id, name: hello.device.deviceName, device: hello.device)

        func reply(_ mode: RemoteServerHello.Mode, then completion: (() -> Void)? = nil) {
            sendPlain(
                RemoteServerHello(
                    protocolVersion: RemoteHandshake.protocolVersion,
                    macID: macID,
                    macName: macName,
                    nonce: nonce,
                    mode: mode
                ),
                then: completion
            )
        }

        guard hello.protocolVersion == RemoteHandshake.protocolVersion else {
            // Closed once the answer is out, so the device can say why.
            reply(.unsupportedVersion) { [self] in
                close(.unsupportedVersion)
            }
            return
        }
        if hello.pairedMacIDs.contains(macID), let pairingKey = keyStore.key(forPeer: hello.device.id) {
            reply(.resume)
            startSession(
                with: peer,
                pairingKey: pairingKey,
                deviceNonce: hello.nonce,
                macNonce: nonce,
                isNewPairing: false
            )
        } else {
            let privateKey = Curve25519.KeyAgreement.PrivateKey()
            let macPublicKey = privateKey.publicKey.rawRepresentation
            let pairing = try RemotePairing.pair(
                privateKey: privateKey,
                devicePublicKey: hello.pairingPublicKey,
                macPublicKey: macPublicKey
            )
            reply(.pair(publicKey: macPublicKey))
            startSession(
                with: peer,
                pairingKey: pairing.pairingKey,
                deviceNonce: hello.nonce,
                macNonce: nonce,
                isNewPairing: true
            )
            emit(.pairingCode(pairing.code, peer))
        }
    }

    /// The device's side: follow the Mac's choice.
    func handle(
        _ hello: RemoteServerHello,
        nonce: Data,
        privateKey: Curve25519.KeyAgreement.PrivateKey
    ) throws {
        let peer = Peer(id: hello.macID, name: hello.macName, device: nil)
        switch hello.mode {
        case .unsupportedVersion:
            close(.unsupportedVersion)
        case .resume:
            guard let pairingKey = keyStore.key(forPeer: hello.macID) else {
                close(.authenticationFailed)
                return
            }
            startSession(
                with: peer,
                pairingKey: pairingKey,
                deviceNonce: nonce,
                macNonce: hello.nonce,
                isNewPairing: false
            )
        case .pair(let macPublicKey):
            let pairing = try RemotePairing.pair(
                privateKey: privateKey,
                devicePublicKey: privateKey.publicKey.rawRepresentation,
                macPublicKey: macPublicKey
            )
            startSession(
                with: peer,
                pairingKey: pairing.pairingKey,
                deviceNonce: nonce,
                macNonce: hello.nonce,
                isNewPairing: true
            )
            emit(.pairingCode(pairing.code, peer))
        }
    }

    func startSession(
        with peer: Peer,
        pairingKey: SymmetricKey,
        deviceNonce: Data,
        macNonce: Data,
        isNewPairing: Bool
    ) {
        cipher = RemoteFrameCipher(
            pairingKey: pairingKey,
            deviceNonce: deviceNonce,
            macNonce: macNonce,
            isDevice: isDevice
        )
        state = .securing(Session(peer: peer, pairingKey: pairingKey, isNewPairing: isNewPairing))
        // A resumed pairing needs no one to compare codes, so this side accepts the other at once.
        if !isNewPairing {
            markLocallyReady()
        }
    }

    func markLocallyReady() {
        guard case .securing(var session) = state, !session.isLocallyReady else { return }
        sendSealed(.ready)
        session.isLocallyReady = true
        state = .securing(session)
        connectIfBothReady()
    }

    func connectIfBothReady() {
        guard case .securing(let session) = state, session.isLocallyReady, session.isRemotelyReady else { return }
        if session.isNewPairing {
            keyStore.save(session.pairingKey, forPeer: session.peer.id)
        }
        state = .connected(session.peer)
        emit(.connected(session.peer))
    }
}

// MARK: - Writing

private extension RemoteConnection {

    func sendPlain<T: Encodable>(_ value: T, then completion: (() -> Void)? = nil) {
        do {
            write(try RemoteFrame.encode(try JSONEncoder().encode(value)), then: completion)
        } catch {
            close(.failed("\(error)"))
        }
    }

    func sendSealed(_ message: RemoteMessage, then completion: (() -> Void)? = nil) {
        do {
            guard let sealed = try cipher?.seal(try JSONEncoder().encode(message)) else { return }
            write(try RemoteFrame.encode(sealed), then: completion)
        } catch {
            NSLog("Sentinel couldn't send a message to the other side: %@", "\(error)")
        }
    }

    func write(_ frame: Data, then completion: (() -> Void)? = nil) {
        backlog.add(frame.count)
        connection.send(content: frame, completion: .contentProcessed { [weak self] _ in
            self?.backlog.remove(frame.count)
            completion?()
        })
    }
}
