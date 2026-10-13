//
//  MacConnectionStoreTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import CryptoKit
import Foundation
import Testing
@testable import Sentinel

@Suite("Mac connection store")
struct MacConnectionStoreTests {

    private let directory: TemporaryDirectory

    init() throws {
        directory = try TemporaryDirectory()
    }

    @Test("Starts off, with no pairings")
    func defaults() {
        let store = makeStore()

        #expect(!store.isEnabled)
        #expect(store.lastMacName == nil)
        #expect(store.pairedPeerIDs.isEmpty)
    }

    @Test("Keeps everything across launches")
    func persists() {
        let key = SymmetricKey(size: .bits256)
        let store = makeStore()
        store.isEnabled = true
        store.lastMacName = "Studio"
        store.save(key, forPeer: "mac")

        let relaunched = makeStore()

        #expect(relaunched.deviceID == store.deviceID)
        #expect(relaunched.isEnabled)
        #expect(relaunched.lastMacName == "Studio")
        #expect(relaunched.pairedPeerIDs == ["mac"])
        #expect(relaunched.key(forPeer: "mac")?.data == key.data)
    }

    @Test("Forgets a removed key")
    func removeKey() {
        let store = makeStore()
        store.save(SymmetricKey(size: .bits256), forPeer: "mac")

        store.removeKey(forPeer: "mac")

        #expect(makeStore().key(forPeer: "mac") == nil)
    }

    @Test("Lives next to the API mocks, out of ClearAppDataTool's reach")
    func defaultLocation() {
        #expect(
            MacConnectionStore.defaultFileURL.deletingLastPathComponent()
                == APIMockPersistence.defaultFileURL.deletingLastPathComponent()
        )
    }

    private func makeStore() -> MacConnectionStore {
        MacConnectionStore(fileURL: directory.url.appendingPathComponent("MacConnection.json"))
    }
}
