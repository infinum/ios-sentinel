//
//  RemoteCrypto.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import CryptoKit
import Foundation

// A device and a Mac pair once. Each sends a one-time Curve25519 public key, both derive the same secret,
// and each shows a six-digit code computed from it. Matching codes mean nobody in between swapped the keys,
// so both sides keep a pairing key derived from the secret. Every connection then derives its own session
// keys from the pairing key and a random nonce from each side, and seals each frame with ChaChaPoly.
//
// TLS with pre-shared keys would do the same job, but a TLS server can't pick the key for a connection
// after the device says who it is, so the Mac would have to restart its listener after every pairing.

// MARK: - Pairing

enum RemotePairing {

    struct Result {
        let pairingKey: SymmetricKey
        let code: String
    }

    /// Derives the pairing key and the code to compare. Both sides pass the same two public keys, in the same order.
    static func pair(
        privateKey: Curve25519.KeyAgreement.PrivateKey,
        devicePublicKey: Data,
        macPublicKey: Data
    ) throws -> Result {
        let ownPublicKey = privateKey.publicKey.rawRepresentation
        let peerPublicKey = ownPublicKey == devicePublicKey ? macPublicKey : devicePublicKey
        let secret = try privateKey.sharedSecretFromKeyAgreement(
            with: try Curve25519.KeyAgreement.PublicKey(rawRepresentation: peerPublicKey)
        )
        let transcript = devicePublicKey + macPublicKey
        let pairingKey = secret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: transcript,
            sharedInfo: Data("Sentinel pairing key".utf8),
            outputByteCount: 32
        )
        let codeKey = secret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: transcript,
            sharedInfo: Data("Sentinel pairing code".utf8),
            outputByteCount: 8
        )
        let number = codeKey.withUnsafeBytes { bytes in
            bytes.reduce(UInt64(0)) { $0 << 8 | UInt64($1) }
        }
        return Result(
            pairingKey: pairingKey,
            code: String(format: "%06llu", number % 1_000_000)
        )
    }

    static func makeNonce() -> Data {
        Data(SymmetricKey(size: .bits256).withUnsafeBytes { Array($0) })
    }
}

extension String {

    /// `123 456`, easier to compare at a glance than `123456`.
    var formattedPairingCode: String {
        guard count == 6 else { return self }
        return "\(prefix(3)) \(suffix(3))"
    }
}

// MARK: - Session

/// Seals the frames one side sends and opens the frames it receives, for the length of one connection.
struct RemoteFrameCipher {

    private static let tagSize = 16

    private let sendingKey: SymmetricKey
    private let receivingKey: SymmetricKey
    // Each direction has its own key, so a counter per direction is a nonce that's never reused.
    private var sentCount: UInt64 = 0
    private var receivedCount: UInt64 = 0

    init(
        pairingKey: SymmetricKey,
        deviceNonce: Data,
        macNonce: Data,
        isDevice: Bool
    ) {
        let salt = deviceNonce + macNonce
        let deviceToMac = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: pairingKey,
            salt: salt,
            info: Data("Sentinel device to Mac".utf8),
            outputByteCount: 32
        )
        let macToDevice = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: pairingKey,
            salt: salt,
            info: Data("Sentinel Mac to device".utf8),
            outputByteCount: 32
        )
        sendingKey = isDevice ? deviceToMac : macToDevice
        receivingKey = isDevice ? macToDevice : deviceToMac
    }

    mutating func seal(_ plaintext: Data) throws -> Data {
        let box = try ChaChaPoly.seal(plaintext, using: sendingKey, nonce: Self.nonce(for: sentCount))
        sentCount += 1
        return box.ciphertext + box.tag
    }

    /// Fails for a frame sealed with another key, changed on the way, or out of order.
    mutating func open(_ frame: Data) throws -> Data {
        guard frame.count >= Self.tagSize else { throw CryptoKitError.authenticationFailure }
        let box = try ChaChaPoly.SealedBox(
            nonce: Self.nonce(for: receivedCount),
            ciphertext: frame.dropLast(Self.tagSize),
            tag: frame.suffix(Self.tagSize)
        )
        let plaintext = try ChaChaPoly.open(box, using: receivingKey)
        receivedCount += 1
        return plaintext
    }

    private static func nonce(for counter: UInt64) throws -> ChaChaPoly.Nonce {
        var bigEndianCounter = counter.bigEndian
        return try ChaChaPoly.Nonce(data: Data(count: 4) + Data(bytes: &bigEndianCounter, count: 8))
    }
}
