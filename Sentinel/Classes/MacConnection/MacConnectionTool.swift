//
//  MacConnectionTool.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(iOS)

import SwiftUI

/// Tool which connects the app to Sentinel Companion, which shows the app's network traffic live and controls
/// its API mocks.
///
/// The first connection to a Mac pairs the two: both show a six-digit code, and the user allows the
/// connection on the Mac after checking the codes match. Later connections are made without asking, and
/// everything sent between the two is encrypted.
///
/// Finding Macs needs local network access, so the app's Info.plist needs `NSLocalNetworkUsageDescription`
/// and `_sentinel._tcp` under `NSBonjourServices`. Nothing is searched for, and the system doesn't ask for
/// access, until the connection is switched on in the tool. Once on, it stays on across launches.
public struct MacConnectionTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Lifecycle

    /// - Parameter name: Name of the tool.
    public init(name: String = "Connect to Mac") {
        self.name = name
        DeviceSession.shared.activate()
    }
}

// MARK: - UI

public extension MacConnectionTool {

    var content: any View {
        MacConnectionView(title: name)
    }
}

#endif
