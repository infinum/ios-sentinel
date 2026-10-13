//
//  RemotePairingKeyStore.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import CryptoKit
import Foundation

/// Remembers the pairing keys a device or a Mac shares with the other side, by the other side's id.
///
/// A connection reads and writes it on its own queue, so implementations have to be thread-safe.
protocol RemotePairingKeyStore: AnyObject {

    func key(forPeer id: String) -> SymmetricKey?
    func save(_ key: SymmetricKey, forPeer id: String)
    func removeKey(forPeer id: String)
}

#if os(macOS)

/// The Mac's pairing keys, kept in the Keychain, one item per device.
final class RemoteKeychainKeyStore: RemotePairingKeyStore {

    private let service: String

    init(service: String = "com.infinum.sentinel.companion.pairing") {
        self.service = service
    }

    func key(forPeer id: String) -> SymmetricKey? {
        var query = query(forPeer: id)
        query[kSecReturnData as String] = true
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return SymmetricKey(data: data)
    }

    func save(_ key: SymmetricKey, forPeer id: String) {
        removeKey(forPeer: id)
        var item = query(forPeer: id)
        item[kSecValueData as String] = key.withUnsafeBytes { Data($0) }
        let status = SecItemAdd(item as CFDictionary, nil)
        if status != errSecSuccess {
            NSLog("Sentinel couldn't save the pairing key for %@: %d", id, status)
        }
    }

    func removeKey(forPeer id: String) {
        SecItemDelete(query(forPeer: id) as CFDictionary)
    }

    private func query(forPeer id: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id
        ]
    }
}

#endif
