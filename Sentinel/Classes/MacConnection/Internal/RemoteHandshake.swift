//
//  RemoteHandshake.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// The first two frames of a connection, sent as plain JSON. They agree on the keys that seal every later frame.
enum RemoteHandshake {

    /// Raised whenever the wire format changes in a way an older peer can't read.
    static let protocolVersion = 1
}

/// The device's opening frame.
struct RemoteClientHello: Codable, Equatable {

    var protocolVersion: Int
    var device: RemoteDeviceInfo
    /// Macs the device has a pairing key for, so the Mac knows whether to resume a pairing or start a new one.
    var pairedMacIDs: [String]
    var nonce: Data
    /// The device's one-time key, used when the Mac starts a new pairing.
    var pairingPublicKey: Data
}

/// The Mac's answer to ``RemoteClientHello``.
struct RemoteServerHello: Codable, Equatable {

    enum Mode: Codable, Equatable {
        /// Both sides have a pairing key, and the connection continues sealed with it.
        case resume
        /// A new pairing, with the Mac's one-time key. Both sides show a code for the user to compare.
        case pair(publicKey: Data)
        /// The Mac speaks another version of the protocol and closes the connection.
        case unsupportedVersion
    }

    var protocolVersion: Int
    var macID: String
    var macName: String
    var nonce: Data
    var mode: Mode
}

/// Who's on the other end of a connection from a Mac: the app and the device it runs on.
struct RemoteDeviceInfo: Codable, Equatable, Identifiable {

    /// Identifies the app on the device. It's generated once and kept with the pairings.
    var id: String
    var deviceName: String
    var systemVersion: String
    var appName: String
    var bundleID: String
    var appVersion: String
}

#if os(iOS)

extension RemoteDeviceInfo {

    static func current(id: String) -> RemoteDeviceInfo {
        let info = Bundle.main.infoDictionary ?? [:]
        let appName = info["CFBundleDisplayName"] as? String ?? info["CFBundleName"] as? String ?? "App"
        return RemoteDeviceInfo(
            id: id,
            deviceName: UIDevice.current.name,
            systemVersion: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            appName: appName,
            bundleID: Bundle.main.bundleIdentifier ?? "",
            appVersion: info["CFBundleShortVersionString"] as? String ?? ""
        )
    }
}

#endif
