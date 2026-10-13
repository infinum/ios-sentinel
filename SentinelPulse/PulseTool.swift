//
//  PulseTool.swift
//  SentinelPulse
//
//  Created by Nikola Simunko on 12.10.2026..
//

#if os(iOS)

import SwiftUI
import Sentinel
import Pulse
import PulseUI

/// Tool which shows the Pulse console with the app's logs and network requests.
///
/// While the app is connected to Sentinel for Mac through `MacConnectionTool`, the requests Pulse logs
/// also show up live on the Mac.
///
/// Pulse removed its embeddable macOS console in 5.0, so the tool is available on iOS only.
/// Pulse 5.2 and newer require iOS 18 to show the console; on older systems Pulse shows
/// an "Unsupported" placeholder instead.
public struct PulseTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Private properties

    private let store: LoggerStore

    // MARK: - Lifecycle

    /// Creates the Pulse tool.
    ///
    /// - Parameters:
    ///   - store: The store whose logs are shown. Defaults to `LoggerStore.shared`.
    ///   - name: The name of the tool. Defaults to "Pulse".
    public init(store: LoggerStore = .shared, name: String = "Pulse") {
        self.store = store
        self.name = name
        PulseNetworkForwarder.start(for: store)
    }
}

public extension PulseTool {

    var content: any View {
        // The console is pushed onto Sentinel's navigation stack, which already provides a back button.
        ConsoleView(store: store)
            .closeButtonHidden()
    }
}

#endif
