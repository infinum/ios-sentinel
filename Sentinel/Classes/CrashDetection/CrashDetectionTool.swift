//
//  CrashDetectionTool.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

// Inspiration link: https://github.com/DebugSwift/DebugSwift

import SwiftUI

/// Tool which gives the ability to catch, and store a stack trace for the crash
public struct CrashDetectionTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Lifecycle

    public init(name: String = "Crash Detection Tool") {
        self.name = name
        CrashFileManager.register()
    }
}

// MARK: - UI

public extension CrashDetectionTool {

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View {
        CrashDetectionToolView()
    }
    #else
    var content: any View {
        CrashDetectionToolView()
    }
    #endif
}
