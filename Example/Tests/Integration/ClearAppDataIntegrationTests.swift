//
//  ClearAppDataIntegrationTests.swift
//  Sentinel_Tests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Security
import Testing
@testable import Sentinel

extension IntegrationTests {

    /// Clears the host app's real data stores, which is why these run inside the example app.
    @Suite("Clear app data")
    struct ClearAppDataIntegrationTests {

        private let keychainService = "com.infinum.sentinel.tests.\(UUID().uuidString)"

        @Test("The Keychain cleaner removes stored passwords")
        func keychainIsCleared() throws {
            try addPassword()
            #expect(passwordExists())

            let failures = KeychainCleaner.clear()

            #expect(failures.filter { $0.kind == .failed }.isEmpty, "\(failures.map(\.reason))")
            #expect(!passwordExists())
        }

        @Test("The UserDefaults cleaner removes the app's defaults")
        func userDefaultsAreCleared() {
            UserDefaults.standard.set("value", forKey: "sentinel.tests.cleared")

            let failures = UserDefaultsCleaner.clear()

            #expect(failures.isEmpty)
            #expect(UserDefaults.standard.object(forKey: "sentinel.tests.cleared") == nil)
        }

        @Test("The cookie cleaner removes every cookie")
        func cookiesAreCleared() throws {
            let cookie = try #require(
                HTTPCookie(
                    properties: [
                        .name: "session",
                        .value: "1",
                        .domain: "example.com",
                        .path: "/"
                    ]
                )
            )
            HTTPCookieStorage.shared.setCookie(cookie)

            let failures = WebDataCleaner.clearCookies()

            #expect(failures.isEmpty)
            #expect(HTTPCookieStorage.shared.cookies?.isEmpty ?? true)
        }

        @Test("Clearing everything empties the temporary and Caches directories")
        func clearAll() async throws {
            let temporaryFile = FileSystemCleaner.temporaryDirectoryURL.appendingPathComponent("sentinel-tests.txt")
            let cachesFile = try #require(FileSystemCleaner.url(for: .cachesDirectory)).appendingPathComponent("sentinel-tests.txt")
            try Data("tmp".utf8).write(to: temporaryFile)
            try Data("cache".utf8).write(to: cachesFile)
            try addPassword()

            let report = await withCheckedContinuation { continuation in
                AppDataCleaner.clearAll { continuation.resume(returning: $0) }
            }

            #expect(report.isFullySuccessful, "\(report.message)")
            #expect(!FileManager.default.fileExists(atPath: temporaryFile.path))
            #expect(!FileManager.default.fileExists(atPath: cachesFile.path))
            #expect(!passwordExists())
        }
    }
}

private extension IntegrationTests.ClearAppDataIntegrationTests {

    func addPassword() throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: "tester",
            kSecValueData: Data("secret".utf8)
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        try #require(status == errSecSuccess, "SecItemAdd failed with \(status)")
    }

    func passwordExists() -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }
}
