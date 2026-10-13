//
//  RemoteFrame.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Splits the TCP stream between Sentinel and Sentinel for Mac into frames: a big-endian `UInt32` length
/// followed by that many bytes.
enum RemoteFrame {

    enum FrameError: Error, Equatable {
        case tooLarge(Int)
    }

    /// Larger frames are refused rather than buffered, so a broken peer can't make the other side run out of memory.
    static let maximumSize = 16 * 1024 * 1024
    static let headerSize = 4

    static func encode(_ payload: Data) throws -> Data {
        guard payload.count <= maximumSize else { throw FrameError.tooLarge(payload.count) }
        var length = UInt32(payload.count).bigEndian
        var frame = Data(bytes: &length, count: headerSize)
        frame.append(payload)
        return frame
    }
}

/// Collects received bytes, which arrive in chunks unrelated to frames, and hands out the complete frames.
struct RemoteFrameDecoder {

    private var buffer = Data()

    /// Adds received bytes and returns the frames they complete, in order.
    mutating func append(_ data: Data) throws -> [Data] {
        buffer.append(data)
        var frames: [Data] = []
        while buffer.count >= RemoteFrame.headerSize {
            let length = buffer.prefix(RemoteFrame.headerSize).reduce(0) { $0 << 8 | Int($1) }
            guard length <= RemoteFrame.maximumSize else { throw RemoteFrame.FrameError.tooLarge(length) }
            let payloadStart = buffer.startIndex + RemoteFrame.headerSize
            let payloadEnd = payloadStart + length
            guard buffer.endIndex >= payloadEnd else { break }
            frames.append(buffer.subdata(in: payloadStart..<payloadEnd))
            buffer.removeSubrange(buffer.startIndex..<payloadEnd)
        }
        return frames
    }
}
