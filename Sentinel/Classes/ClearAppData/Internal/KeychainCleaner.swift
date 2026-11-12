//
//  KeychainCleaner.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

#if os(iOS)

import Foundation
import Security

/// Removes the app's keychain items.
///
/// Keychain items survive deleting and reinstalling the app, so they're cleared here to get the app
/// back to a clean state.
enum KeychainCleaner {

    private static let itemClasses: [CFString] = [
        kSecClassGenericPassword,
        kSecClassInternetPassword,
        kSecClassCertificate,
        kSecClassKey,
        kSecClassIdentity
    ]

    static func clear() -> [ClearAppDataFailure] {
        // An unscoped delete reaches every group in the entitlement, which would take a sibling
        // app's or an extension's shared credentials with it, so nothing is deleted without a group.
        guard let accessGroup = appAccessGroup() else {
            return [ClearAppDataFailure(
                step: .keychain,
                reason: "could not determine the app's access group, keychain was not cleared"
            )]
        }

        return itemClasses.compactMap { itemClass in
            let query: [CFString: Any] = [
                kSecClass: itemClass,
                kSecAttrAccessGroup: accessGroup,
                // Without this, items synchronised to iCloud are left behind.
                kSecAttrSynchronizable: kSecAttrSynchronizableAny
            ]

            let status = SecItemDelete(query as CFDictionary)
            guard status != errSecSuccess, status != errSecItemNotFound else { return nil }
            return ClearAppDataFailure(
                step: .keychain,
                item: description(of: itemClass),
                reason: "OSStatus \(status)"
            )
        }
    }
}

// MARK: - Helpers

private extension KeychainCleaner {

    static let probeService = "com.infinum.sentinel.clearAppData.accessGroupProbe"

    /// Returns the app's own keychain access group, `<app ID prefix>.<bundle ID>`.
    ///
    /// There is no API that reports it directly. The default group is the first entry in
    /// `keychain-access-groups`, which can be a group shared with other apps, so it can't be used
    /// as is. Instead an item is written without an access group, which lands it in the default
    /// one, and the app ID prefix is taken from the group it was assigned.
    static func appAccessGroup() -> String? {
        guard
            let bundleIdentifier = Bundle.main.bundleIdentifier,
            let defaultGroup = probeDefaultAccessGroup()
        else { return nil }

        // Builds without a signing team get a bare group such as `test`. They have no entitlement
        // to share anything, so the group is already the app's own.
        guard let prefixEnd = defaultGroup.firstIndex(of: ".") else { return defaultGroup }
        return "\(defaultGroup[..<prefixEnd]).\(bundleIdentifier)"
    }

    static func probeDefaultAccessGroup() -> String? {
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

#endif
