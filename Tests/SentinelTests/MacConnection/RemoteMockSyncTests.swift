//
//  RemoteMockSyncTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("API mocks between the device and the Mac")
struct RemoteMockSyncTests {

    private let directory: TemporaryDirectory
    private let empty = APIMock(name: "Empty", url: .wildcard("/products"), body: .json("[]"))
    private let failure = APIMock(name: "Failure", url: .wildcard("/products"), statusCode: 500, body: .json("{}"))

    init() throws {
        directory = try TemporaryDirectory()
    }

    @Test("The device sends its mocks and switches as soon as the bridge starts")
    func initialSnapshot() {
        let store = makeStore()
        store.setAppMocks([empty])
        var messages: [RemoteMessage] = []

        _ = RemoteMockBridge(store: store) { messages.append($0) }

        #expect(messages == [
            .mocks([RemoteMock(mock: empty, isLocal: false)]),
            .mockSwitches(RemoteMockSwitches(isMockingEnabled: true, enabledIDs: []))
        ])
    }

    @Test("Switching a mock on from the Mac goes through the device's rules")
    func setEnabled() {
        let store = makeStore()
        store.setAppMocks([empty, failure])
        store.setEnabled(true, for: empty)
        var messages: [RemoteMessage] = []
        let bridge = RemoteMockBridge(store: store) { messages.append($0) }
        messages = []

        bridge.apply(.setEnabled(id: failure.id, isEnabled: true))

        #expect(store.enabledIDs == [failure.id])
        #expect(messages.last == .mockSwitches(RemoteMockSwitches(isMockingEnabled: true, enabledIDs: [failure.id])))
    }

    @Test("A mock saved on the Mac becomes a local mock on the device")
    func save() {
        let store = makeStore()
        let bridge = RemoteMockBridge(store: store) { _ in }
        let mock = APIMock(id: "local.1", name: "New", url: .wildcard("/new"), body: .json("{}"))

        bridge.apply(.save(RemoteMock(mock: mock, isLocal: true)))

        #expect(store.localMocks == [mock])
    }

    @Test("The Mac can't overwrite a mock the app ships with")
    func saveOverAppMock() {
        let store = makeStore()
        store.setAppMocks([empty])
        let bridge = RemoteMockBridge(store: store) { _ in }

        bridge.apply(.save(RemoteMock(mock: empty, isLocal: true)))

        #expect(store.localMocks.isEmpty)
    }

    @Test("Deleting from the Mac removes only local mocks")
    func delete() {
        let store = makeStore()
        let local = APIMock(id: "local.1", name: "Local", url: .wildcard("/local"), body: .json("{}"))
        store.setAppMocks([empty])
        store.save(local)
        let bridge = RemoteMockBridge(store: store) { _ in }

        bridge.apply(.delete(id: empty.id))
        bridge.apply(.delete(id: local.id))

        #expect(store.appMocks == [empty])
        #expect(store.localMocks.isEmpty)
    }

    @Test("The Mac's copy splits the mocks and keeps the device's warnings")
    func macCopy() {
        let store = RemoteAPIMockStore { _ in }
        var appMock = RemoteMock(mock: empty, isLocal: false)
        appMock.warning = "Missing body file products.json."
        let localMock = RemoteMock(mock: failure, isLocal: true)

        store.apply([localMock, appMock])
        store.apply(RemoteMockSwitches(isMockingEnabled: true, enabledIDs: [empty.id]))

        #expect(store.localMocks == [failure])
        #expect(store.appMocks == [empty])
        #expect(store.warning(for: empty) == "Missing body file products.json.")
        #expect(store.activeMocks == [empty])
    }

    @Test("The Mac's copy skips a mock it can't read")
    func unreadableMock() {
        let store = RemoteAPIMockStore { _ in }
        var unreadable = RemoteMock(mock: empty, isLocal: false)
        unreadable.matchKind = "glob"

        store.apply([unreadable, RemoteMock(mock: failure, isLocal: false)])

        #expect(store.appMocks == [failure])
    }

    @Test("Changes on the Mac only send commands, and the copy waits for the device")
    func macCommands() {
        var commands: [RemoteMockCommand] = []
        let store = RemoteAPIMockStore { commands.append($0) }
        store.apply([RemoteMock(mock: empty, isLocal: false)])

        store.setEnabled(true, for: empty)
        store.setMockingEnabled(false)
        store.delete(empty)

        #expect(commands == [
            .setEnabled(id: empty.id, isEnabled: true),
            .setMockingEnabled(false),
            .delete(id: empty.id)
        ])
        #expect(store.enabledIDs.isEmpty)
        #expect(store.isMockingEnabled)
    }

    private func makeStore() -> APIMockStore {
        APIMockStore(
            persistence: APIMockPersistence(fileURL: directory.url.appendingPathComponent("APIMocking.json")),
            matcher: APIMockMatcher()
        )
    }
}
