//
//  RemoteMessage.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// What Sentinel and Sentinel for Mac send each other once the handshake has agreed on keys.
enum RemoteMessage: Codable, Equatable {

    /// The sender accepts the other side. Sent at once when a pairing resumes, and after the user compares
    /// the codes of a new one.
    case ready
    /// The user turned the pairing down.
    case rejected
    case ping
    case pong

    // MARK: Device to Mac

    case mocks([RemoteMock])
    case mockSwitches(RemoteMockSwitches)

    // MARK: Mac to device

    case mockCommand(RemoteMockCommand)
}
