//
//  StoredDataProvider.swift
//  Example-iOS
//
//  Created by Nikola Simunko on 22.09.2025..
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import Security

/// Writes a timestamp to both user defaults and the keychain, so that `ClearAppDataTool` can be
/// seen clearing each of them independently.
enum StoredDataProvider {

    private static let userDefaultsKey = "com.infinum.demo.clearDataTool.lastSavedDate"
    // No access group is set, so the item lands in the app's default one — the group the tool
    // scopes its keychain delete to.
    private static let keychainService = "com.infinum.demo.clearDataTool"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy. HH:mm:ss"
        return formatter
    }()

    static func save(_ date: Date = Date()) {
        let value = formatter.string(from: date)
        UserDefaults.standard.set(value, forKey: userDefaultsKey)
        saveToKeychain(value)
    }

    static var userDefaultsValue: String? {
        UserDefaults.standard.string(forKey: userDefaultsKey)
    }

    static var keychainValue: String? {
        var query = keychainIdentity
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne

        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Helpers

private extension StoredDataProvider {

    static var keychainIdentity: [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: keychainService
        ]
    }

    static func saveToKeychain(_ value: String) {
        _ = SecItemDelete(keychainIdentity as CFDictionary)

        var attributes = keychainIdentity
        attributes[kSecValueData] = Data(value.utf8)
        _ = SecItemAdd(attributes as CFDictionary, nil)
    }
}
