//
//  KeychainCleaner.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import Foundation
import Security

/// Removes the app's keychain items.
///
/// Keychain items are removed when an app is uninstalled, so clearing them is part of restoring a
/// freshly installed state — deleting the app container alone leaves them behind.
enum KeychainCleaner {

    private static let itemClasses: [CFString] = [
        kSecClassGenericPassword,
        kSecClassInternetPassword,
        kSecClassCertificate,
        kSecClassKey,
        kSecClassIdentity
    ]

    static func clear() -> [ClearAppDataFailure] {
        var failures: [ClearAppDataFailure] = []
        let accessGroup = defaultAccessGroup()

        if accessGroup == nil {
            failures.append(ClearAppDataFailure(
                step: .keychain,
                reason: "could not determine the app's access group, cleared all entitled groups",
                kind: .warning
            ))
        }

        for itemClass in itemClasses {
            var query: [CFString: Any] = [
                kSecClass: itemClass,
                // Without this, items synchronised to iCloud are left behind.
                kSecAttrSynchronizable: kSecAttrSynchronizableAny
            ]
            // Scoping the delete keeps it inside the app's own group. An unscoped delete reaches
            // every group in the entitlement, which would take a sibling app's or an extension's
            // shared credentials with it.
            if let accessGroup {
                query[kSecAttrAccessGroup] = accessGroup
            }

            let status = SecItemDelete(query as CFDictionary)
            guard status != errSecSuccess, status != errSecItemNotFound else { continue }
            failures.append(ClearAppDataFailure(
                step: .keychain,
                item: description(of: itemClass),
                reason: "OSStatus \(status)"
            ))
        }

        return failures
    }
}

// MARK: - Helpers

private extension KeychainCleaner {

    static let probeService = "com.infinum.sentinel.clearAppData.accessGroupProbe"

    /// Discovers the app's default keychain access group.
    ///
    /// There is no API that reports it directly, so an item is written without an access group —
    /// which lands it in the default one — and its assigned group is read back.
    static func defaultAccessGroup() -> String? {
        let identity: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: probeService,
            kSecAttrAccount: probeService
        ]

        // A probe left behind by an interrupted run would make the add fail as a duplicate.
        _ = SecItemDelete(identity as CFDictionary)

        var attributes = identity
        attributes[kSecValueData] = Data()
        guard SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess else { return nil }
        defer { _ = SecItemDelete(identity as CFDictionary) }

        var query = identity
        query[kSecReturnAttributes] = true
        query[kSecMatchLimit] = kSecMatchLimitOne

        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return (result as? [CFString: Any])?[kSecAttrAccessGroup] as? String
    }

    static func description(of itemClass: CFString) -> String {
        switch itemClass {
        case kSecClassGenericPassword: return "generic passwords"
        case kSecClassInternetPassword: return "internet passwords"
        case kSecClassCertificate: return "certificates"
        case kSecClassKey: return "keys"
        case kSecClassIdentity: return "identities"
        default: return itemClass as String
        }
    }
}
