//
//  RemoteNetworkTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Remote network log")
struct RemoteNetworkTests {

    // MARK: - Entries

    @Test("A body over the limit is cut off and remembers its full size")
    func truncatedBody() {
        let body = RemoteNetworkEntry.Body(data: Data(count: RemoteNetworkEntry.maximumBodySize + 10))

        #expect(body.data.count == RemoteNetworkEntry.maximumBodySize)
        #expect(body.size == RemoteNetworkEntry.maximumBodySize + 10)
        #expect(body.isTruncated)
    }

    @Test("A body within the limit is kept whole")
    func wholeBody() {
        let body = RemoteNetworkEntry.Body(data: Data("{}".utf8))

        #expect(body.data == Data("{}".utf8))
        #expect(!body.isTruncated)
    }

    @Test("A request is marked mocked by Pulse's request header or the mock's response header, in any case")
    func mocked() {
        #expect(RemoteNetworkEntry.isMocked(requestHeaders: ["x-pulserequestmocked": "true"], responseHeaders: [:]))
        #expect(RemoteNetworkEntry.isMocked(requestHeaders: [:], responseHeaders: ["X-Sentinel-Mock": "products"]))
        #expect(!RemoteNetworkEntry.isMocked(requestHeaders: ["Accept": "*/*"], responseHeaders: ["Content-Type": "application/json"]))
    }

    // MARK: - Backlog

    @Test("Messages go out while the backlog is under its limit")
    func underLimit() {
        var backlog = RemoteBacklog(limit: 100)
        backlog.add(99)

        #expect(backlog.messages(for: .networkEntry(entry()), isDroppable: true).count == 1)
    }

    @Test("Droppable messages are left out over the limit, and counted when the backlog clears")
    func overLimit() {
        var backlog = RemoteBacklog(limit: 100)
        let first = entry()
        let second = entry()
        backlog.add(100)

        #expect(backlog.messages(for: .networkEntry(first), isDroppable: true).isEmpty)
        #expect(backlog.messages(for: .ping, isDroppable: false) == [.ping])

        backlog.remove(100)

        #expect(backlog.messages(for: .networkEntry(second), isDroppable: true) == [.droppedNetworkEntries(1), .networkEntry(second)])
        #expect(backlog.messages(for: .networkEntry(first), isDroppable: true) == [.networkEntry(first)])
    }

    // MARK: - Recorder

    @Test("Nothing is recorded while the Mac connection is off")
    func offRecordsNothing() {
        let recorder = RemoteNetworkRecorder()

        recorder.record(entry())

        #expect(recorder.recordedEntries.isEmpty)
    }

    @Test("A finished request replaces its started entry and moves to the end")
    func replacesEntry() {
        let recorder = RemoteNetworkRecorder()
        recorder.setRecording(true)
        var started = entry()
        let other = entry()
        recorder.record(started)
        recorder.record(other)

        started.duration = 0.2
        recorder.record(started)

        #expect(recorder.recordedEntries == [other, started])
    }

    @Test("The oldest requests go once the kept ones exceed the budget")
    func budget() {
        let first = entry(bodySize: 60)
        let second = entry(bodySize: 60)
        let recorder = RemoteNetworkRecorder(maximumSize: first.approximateSize + 10)
        recorder.setRecording(true)

        recorder.record(first)
        recorder.record(second)

        #expect(recorder.recordedEntries == [second])
    }

    @Test("A connected Mac gets the kept requests first, then each new one")
    func forwarding() {
        let recorder = RemoteNetworkRecorder()
        recorder.setRecording(true)
        let kept = entry()
        let new = entry()
        recorder.record(kept)
        var forwarded: [RemoteNetworkEntry] = []

        recorder.startForwarding { forwarded.append($0) }
        recorder.record(new)
        recorder.stopForwarding()
        recorder.record(entry())

        #expect(forwarded == [kept, new])
    }

    @Test("Switching the connection off forgets the kept requests")
    func switchingOff() {
        let recorder = RemoteNetworkRecorder()
        recorder.setRecording(true)
        recorder.record(entry())

        recorder.setRecording(false)

        #expect(recorder.recordedEntries.isEmpty)
    }

    // MARK: - Over the connection

    @Test("Requests reach the Mac over the connection")
    func overConnection() async throws {
        let loopback = try RemoteLoopback()
        try await loopback.start()
        try await loopback.pair()
        let request = entry(bodySize: 2_000)

        loopback.deviceConnection?.send(.networkEntry(request), isDroppable: true)

        #expect(try await loopback.macEvents.next() == .message(.networkEntry(request)))
    }

    private func entry(bodySize: Int = 0) -> RemoteNetworkEntry {
        RemoteNetworkEntry(
            id: UUID(),
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            method: "GET",
            url: "https://example.com/products",
            requestHeaders: [:],
            responseBody: bodySize > 0 ? RemoteNetworkEntry.Body(data: Data(count: bodySize)) : nil,
            isMocked: false
        )
    }
}
