//
//  DeviceSessionTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(iOS)
import Foundation
import Network
import Testing
@testable import Sentinel

@Suite("Device session")
struct DeviceSessionTests {

    private let directory: TemporaryDirectory
    private let recorder = RemoteNetworkRecorder()

    init() throws {
        directory = try TemporaryDirectory()
    }

    @Test("A Mac reachable over several links is listed once, and the list is sorted by name")
    func listedMacs() {
        let studio = mac("Studio", port: 1)
        let studioOverPeerToPeer = mac("Studio", port: 2)
        let air = mac("air", port: 3)

        #expect(DeviceSession.listed([studio, air, studioOverPeerToPeer]) == [air, studio])
    }

    @Test("Switching on searches, starts recording requests and is remembered")
    func switchingOn() {
        let store = makeStore()
        let session = DeviceSession(store: store, recorder: recorder)

        session.setEnabled(true)
        recorder.record(entry())

        #expect(session.status == .searching)
        // The Simulator reaches the Mac on localhost rather than through Bonjour.
        #expect(session.macs.map(\.name) == ["This Mac"])
        #expect(recorder.recordedEntries.count == 1)
        #expect(makeStore().isEnabled)
    }

    @Test("Switching off stops searching and forgets the recorded requests")
    func switchingOff() {
        let session = DeviceSession(store: makeStore(), recorder: recorder)
        session.setEnabled(true)
        recorder.record(entry())

        session.setEnabled(false)
        recorder.record(entry())

        #expect(session.status == .off)
        #expect(session.macs.isEmpty)
        #expect(recorder.recordedEntries.isEmpty)
    }

    @Test("A session left on resumes when the tool is created")
    func activate() {
        let store = makeStore()
        store.isEnabled = true
        let session = DeviceSession(store: store, recorder: recorder)

        session.activate()

        #expect(session.isEnabled)
        #expect(session.status == .searching)
    }

    private func makeStore() -> MacConnectionStore {
        MacConnectionStore(fileURL: directory.url.appendingPathComponent("MacConnection.json"))
    }

    private func mac(_ name: String, port: UInt16) -> DeviceSession.DiscoveredMac {
        DeviceSession.DiscoveredMac(
            name: name,
            endpoint: NWEndpoint.hostPort(host: "127.0.0.1", port: NWEndpoint.Port(rawValue: port)!)
        )
    }

    private func entry() -> RemoteNetworkEntry {
        RemoteNetworkEntry(
            id: UUID(),
            createdAt: Date(),
            method: "GET",
            url: "https://example.com",
            requestHeaders: [:],
            isMocked: false
        )
    }
}
#endif
