//
//  RemoteService.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Network

/// How Sentinel finds Sentinel for Mac and connects to it.
enum RemoteService {

    /// The Bonjour service the Mac advertises. Apps list it under `NSBonjourServices`.
    static let type = "_sentinel._tcp"

    /// The port the Mac tries to listen on. The iOS Simulator connects to it on localhost rather than through
    /// Bonjour, which macOS 15.4 and 15.5 broke for the Simulator.
    static let preferredPort: NWEndpoint.Port = 47_653

    static func makeParameters() -> NWParameters {
        let tcp = NWProtocolTCP.Options()
        tcp.enableKeepalive = true
        tcp.keepaliveIdle = 5
        let parameters = NWParameters(tls: nil, tcp: tcp)
        // Peer-to-peer Wi-Fi, the link AirDrop uses, reaches a Mac that isn't on the same network.
        parameters.includePeerToPeer = true
        return parameters
    }
}
