//
//  SignalPrehandlerManager.swift
//  MasterConnect
//
//  Created by Zvonimir Medak on 18.04.2024..
//  Copyright © 2024 Signify. All rights reserved.
//

// Inspiration link: https://github.com/DebugSwift/DebugSwift

import Foundation

typealias SignalHandler = (Int32, UnsafeMutablePointer<__siginfo>?, UnsafeMutableRawPointer?) -> Void

final class SignalPrehandlerManager {

    // MARK: - Internal properties -

    private var previousABRTSignalHandler: SignalHandler?
    private var previousBUSSignalHandler: SignalHandler?
    private var previousFPESignalHandler: SignalHandler?
    private var previousILLSignalHandler: SignalHandler?
    private var previousPIPESignalHandler: SignalHandler?
    private var previousSEGVSignalHandler: SignalHandler?
    private var previousSYSSignalHandler: SignalHandler?
    private var previousTRAPSignalHandler: SignalHandler?

}

// MARK: - Extensions -

// MARK: - Helpers

extension SignalPrehandlerManager {

    var preHandlers: [Int32: SignalHandler?] {
        [
            SIGABRT: previousABRTSignalHandler,
            SIGBUS: previousBUSSignalHandler,
            SIGFPE: previousFPESignalHandler,
            SIGILL: previousILLSignalHandler,
            SIGPIPE: previousPIPESignalHandler,
            SIGSEGV: previousSEGVSignalHandler,
            SIGSYS: previousSYSSignalHandler,
            SIGTRAP: previousTRAPSignalHandler
        ]
    }

}
