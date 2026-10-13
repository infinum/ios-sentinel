//
//  RemoteFrameTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Remote frames")
struct RemoteFrameTests {

    @Test("A frame decodes to its payload")
    func roundTrip() throws {
        var decoder = RemoteFrameDecoder()

        let frames = try decoder.append(try RemoteFrame.encode(Data("hello".utf8)))

        #expect(frames == [Data("hello".utf8)])
    }

    @Test("A frame split across reads comes out once it's complete")
    func splitFrame() throws {
        var decoder = RemoteFrameDecoder()
        let frame = try RemoteFrame.encode(Data("hello".utf8))

        let first = try decoder.append(frame.prefix(2))
        let second = try decoder.append(frame.dropFirst(2).prefix(4))
        let third = try decoder.append(frame.dropFirst(6))

        #expect(first.isEmpty)
        #expect(second.isEmpty)
        #expect(third == [Data("hello".utf8)])
    }

    @Test("Frames arriving in one read come out in order")
    func mergedFrames() throws {
        var decoder = RemoteFrameDecoder()
        let data = try RemoteFrame.encode(Data("one".utf8))
            + RemoteFrame.encode(Data())
            + RemoteFrame.encode(Data("three".utf8)).prefix(5)

        let frames = try decoder.append(data)

        #expect(frames == [Data("one".utf8), Data()])
        #expect(try decoder.append(Data("hree".utf8)) == [Data("three".utf8)])
    }

    @Test("A frame announcing more than the maximum size is refused")
    func tooLarge() {
        var decoder = RemoteFrameDecoder()
        var length = UInt32(RemoteFrame.maximumSize + 1).bigEndian
        let header = Data(bytes: &length, count: 4)

        #expect(throws: RemoteFrame.FrameError.tooLarge(RemoteFrame.maximumSize + 1)) {
            try decoder.append(header)
        }
    }

    @Test("A payload over the maximum size isn't encoded")
    func encodeTooLarge() {
        #expect(throws: RemoteFrame.FrameError.tooLarge(RemoteFrame.maximumSize + 1)) {
            try RemoteFrame.encode(Data(count: RemoteFrame.maximumSize + 1))
        }
    }
}
