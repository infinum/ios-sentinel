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

    /// - Parameters:
    ///     - name: Name of the tool
    ///     - shouldObserveUncaughtExceptions: Registers an observer for the uncaught exceptions
    ///     - uncaughtExceptionReceiveHandler: Called when an uncaught exception has been caught, defaults to nil, and saves the crash to the CrashFileManager which can be accessed in the CrashDetectionTool
    ///     - shouldObserveSignalExceptions: Registers an observer for the signal exceptions
    ///     - signalExceptionReceiveHandler: Called when a signal exception has been caught, defaults to nil, and saves the crash to the CrashFileManager which can be accessed in the CrashDetectionTool
    /// - Warning: If you want to save crashes to the both CrashDetectionTool, and to your own database please add the default saving handler to the CrashFileManager to your handler
    public init(
        name: String = "Crash Detection Tool",
        shouldObserveUncaughtExceptions: Bool = true,
        uncaughtExceptionReceiveHandler: ((Int32?, NSException?, String) -> Void)? = nil,
        shouldObserveSignalExceptions: Bool = true,
        signalExceptionReceiveHandler: ((Int32?, NSException?, String) -> Void)? = nil
    ) {
        self.name = name
        if shouldObserveUncaughtExceptions {
            CrashFileManager.registerUncaughtExceptionHandler(exceptionReceiveHandler: uncaughtExceptionReceiveHandler)
        }

        if shouldObserveSignalExceptions {
            CrashFileManager.registerSignalExceptionHandler(exceptionReceiveHandler: signalExceptionReceiveHandler)
        }
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
