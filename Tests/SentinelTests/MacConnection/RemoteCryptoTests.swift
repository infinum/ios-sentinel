//
//  RemoteCryptoTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import CryptoKit
import Foundation
import Testing
@testable import Sentinel

@Suite("Remote pairing and encryption")
struct RemoteCryptoTests {

    @Test("Both sides of a pairing derive the same key and code")
    func pairingAgrees() throws {
        let device = Curve25519.KeyAgreement.PrivateKey()
        let mac = Curve25519.KeyAgreement.PrivateKey()
        let devicePublicKey = device.publicKey.rawRepresentation
        let macPublicKey = mac.publicKey.rawRepresentation

        let onDevice = try RemotePairing.pair(
            privateKey: device,
            devicePublicKey: devicePublicKey,
            macPublicKey: macPublicKey
        )
        let onMac = try RemotePairing.pair(
            privateKey: mac,
            devicePublicKey: devicePublicKey,
            macPublicKey: macPublicKey
        )

        #expect(onDevice.code == onMac.code)
        #expect(onDevice.code.count == 6)
        #expect(onDevice.code.allSatisfy { $0.isNumber })
        #expect(onDevice.pairingKey.data == onMac.pairingKey.data)
    }

    @Test("Someone swapping the keys in between ends up with other codes")
    func swappedKeyChangesCode() throws {
        let device = Curve25519.KeyAgreement.PrivateKey()
        let mac = Curve25519.KeyAgreement.PrivateKey()
        let attacker = Curve25519.KeyAgreement.PrivateKey()

        // The device talks to the attacker, believing it's the Mac, and the Mac to the attacker the other way round.
        let onDevice = try RemotePairing.pair(
            privateKey: device,
            devicePublicKey: device.publicKey.rawRepresentation,
            macPublicKey: attacker.publicKey.rawRepresentation
        )
        let onMac = try RemotePairing.pair(
            privateKey: mac,
            devicePublicKey: attacker.publicKey.rawRepresentation,
            macPublicKey: mac.publicKey.rawRepresentation
        )

        #expect(onDevice.code != onMac.code)
        #expect(onDevice.pairingKey.data != onMac.pairingKey.data)
    }

    @Test("Frames sealed on one side open on the other, in both directions")
    func sealAndOpen() throws {
        var (device, mac) = makeCiphers()

        let toMac = try device.seal(Data("to Mac".utf8))
        let toDevice = try mac.seal(Data("to device".utf8))

        #expect(try mac.open(toMac) == Data("to Mac".utf8))
        #expect(try device.open(toDevice) == Data("to device".utf8))
    }

    @Test("A changed frame doesn't open")
    func tampered() throws {
        var (device, mac) = makeCiphers()
        var frame = try device.seal(Data("to Mac".utf8))
        frame[frame.startIndex] ^= 0xFF

        #expect(throws: (any Error).self) {
            try mac.open(frame)
        }
    }

    @Test("A frame replayed or out of order doesn't open")
    func outOfOrder() throws {
        var (device, mac) = makeCiphers()
        let first = try device.seal(Data("first".utf8))
        let second = try device.seal(Data("second".utf8))

        #expect(throws: (any Error).self) {
            try mac.open(second)
        }
        _ = try mac.open(first)
        #expect(throws: (any Error).self) {
            try mac.open(first)
        }
    }

    @Test("A frame sealed with another pairing key doesn't open")
    func otherKey() throws {
        let nonces = (RemotePairing.makeNonce(), RemotePairing.makeNonce())
        var device = RemoteFrameCipher(
            pairingKey: SymmetricKey(size: .bits256),
            deviceNonce: nonces.0,
            macNonce: nonces.1,
            isDevice: true
        )
        var mac = RemoteFrameCipher(
            pairingKey: SymmetricKey(size: .bits256),
            deviceNonce: nonces.0,
            macNonce: nonces.1,
            isDevice: false
        )

        let frame = try device.seal(Data("to Mac".utf8))

        #expect(throws: (any Error).self) {
            try mac.open(frame)
        }
    }

    @Test("The code reads as two groups of three digits")
    func formattedCode() {
        #expect("012345".formattedPairingCode == "012 345")
    }

    private func makeCiphers() -> (device: RemoteFrameCipher, mac: RemoteFrameCipher) {
        let key = SymmetricKey(size: .bits256)
        let deviceNonce = RemotePairing.makeNonce()
        let macNonce = RemotePairing.makeNonce()
        return (
            RemoteFrameCipher(
                pairingKey: key,
                deviceNonce: deviceNonce,
                macNonce: macNonce,
                isDevice: true
            ),
            RemoteFrameCipher(
                pairingKey: key,
                deviceNonce: deviceNonce,
                macNonce: macNonce,
                isDevice: false
            )
        )
    }
}
