//
//  ClearAppDataTool.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import SwiftUI

#if os(iOS)

/// Tool which wipes the app's stored data, so it can be tested from a clean state without being
/// deleted and reinstalled.
///
/// Clears the app's user defaults and the suites it created, the temporary, Caches, Application
/// Support and Documents directories, the shared URL cache, cookies, web site data, and the
/// keychain items in the app's own access group.
///
/// - Warning: The app must be force quit and relaunched afterwards. iOS cannot restart it, so
/// anything already held in memory — singletons, open database connections, cached credentials —
/// stays live and can leave the app in an inconsistent state until it is relaunched.
/// - Note: Keychain items in shared access groups and data in app group containers are left alone,
/// as both are shared with other apps and extensions. Clearing those remains the host app's
/// responsibility.
public struct ClearAppDataTool: Tool {

    // MARK: - Public properties
    public let name: String

    // MARK: - Lifecycle
    /// - Parameters:
    ///     - name: Name of the tool
    public init(name: String = "Clear App Data") {
        self.name = name
    }
}

// MARK: - UI

public extension ClearAppDataTool {

    var content: any View {
        ClearAppDataView(viewModel: ClearAppDataViewModel(name: name))
    }
}

#endif
