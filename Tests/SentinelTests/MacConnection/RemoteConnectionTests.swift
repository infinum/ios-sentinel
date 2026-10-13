//
//  RemoteConnectionTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import CryptoKit
import Foundation
import Testing
@testable import Sentinel

@Suite("Remote connection over localhost")
struct RemoteConnectionTests {

    @Test("A first connection pairs, with the same code on both sides")
    func pairs() async throws {
        let loopback = try RemoteLoopback()
        try await loopback.start()

        loopback.connectDevice()
        let macCode = try await loopback.macEvents.next { $0.isPairingCode }.pairingCode
        let deviceCode = try await loopback.deviceEvents.next { $0.isPairingCode }.pairingCode

        #expect(macCode != nil)
        #expect(macCode == deviceCode)
        #expect(loopback.macStore.pairedPeerIDs.isEmpty)
    }

    @Test("Both sides keep the key once both users confirm")
    func confirmedPairing() async throws {
        let loopback = try RemoteLoopback()
        try await loopback.start()

        try await loopback.pair()

        #expect(loopback.macStore.pairedPeerIDs == [RemoteLoopback.device.id])
        #expect(loopback.deviceStore.pairedPeerIDs == [RemoteLoopback.macID])
        #expect(
            loopback.macStore.key(forPeer: RemoteLoopback.device.id)?.data
                == loopback.deviceStore.key(forPeer: RemoteLoopback.macID)?.data
        )
    }

    @Test("Confirming on one side only doesn't connect")
    func oneSidedConfirmation() async throws {
        let loopback = try RemoteLoopback()
        try await loopback.start()
        loopback.connectDevice()
        _ = try await loopback.macEvents.next { $0.isPairingCode }

        loopback.macConnection?.confirmPairing()

        await #expect(throws: RemoteEventRecorder.Timeout.self) {
            try await loopback.deviceEvents.next(within: 1) { $0.isConnected }
        }
        #expect(loopback.macStore.pairedPeerIDs.isEmpty)
    }

    @Test("A paired device connects again without a code")
    func resumes() async throws {
        let loopback = try RemoteLoopback()
        try await loopback.start()
        try await loopback.pair()
        loopback.deviceConnection?.cancel()
        _ = try await loopback.macEvents.next { $0.isClosed }

        loopback.connectDevice()

        #expect(try await loopback.deviceEvents.next { !$0.isClosed }.isConnected)
        #expect(try await loopback.macEvents.next().isConnected)
    }

    @Test("Turning the pairing down closes both sides and keeps no key")
    func rejected() async throws {
        let loopback = try RemoteLoopback()
        try await loopback.start()
        loopback.connectDevice()
        _ = try await loopback.deviceEvents.next { $0.isPairingCode }

        loopback.macConnection?.rejectPairing()

        #expect(try await loopback.deviceEvents.next { $0.isClosed } == .closed(.rejected))
        #expect(try await loopback.macEvents.next { $0.isClosed } == .closed(.rejected))
        #expect(loopback.deviceStore.pairedPeerIDs.isEmpty)
    }

    @Test("Keys that no longer match are forgotten, so the next connection pairs again")
    func mismatchedKeys() async throws {
        let loopback = try RemoteLoopback()
        try await loopback.start()
        loopback.macStore.save(SymmetricKey(size: .bits256), forPeer: RemoteLoopback.device.id)
        loopback.deviceStore.save(SymmetricKey(size: .bits256), forPeer: RemoteLoopback.macID)

        loopback.connectDevice()

        #expect(try await loopback.deviceEvents.next { $0.isClosed } == .closed(.authenticationFailed))
        // The Mac sees either the same failure or the device hanging up first, depending on timing.
        _ = try await loopback.macEvents.next { $0.isClosed }
        #expect(loopback.deviceStore.pairedPeerIDs.isEmpty)

        loopback.connectDevice()

        #expect(try await loopback.deviceEvents.next().isPairingCode)
    }

    @Test("A device the Mac forgot pairs again")
    func macForgotDevice() async throws {
        let loopback = try RemoteLoopback()
        try await loopback.start()
        try await loopback.pair()
        loopback.deviceConnection?.cancel()
        _ = try await loopback.macEvents.next { $0.isClosed }
        loopback.macStore.removeKey(forPeer: RemoteLoopback.device.id)

        loopback.connectDevice()

        #expect(try await loopback.deviceEvents.next { !$0.isClosed }.isPairingCode)
    }
}
