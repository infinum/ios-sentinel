//
//  CrashSignalExceptionHandler.swift
//  MasterConnect
//
//  Created by Zvonimir Medak on 18.04.2024..
//  Copyright © 2024 Signify. All rights reserved.
//

// Inspiration link: https://github.com/DebugSwift/DebugSwift

import Foundation

final class CrashSignalExceptionHandler {

    // MARK: - Internal properties -

    static var exceptionReceiveClosure: ((Int32?, NSException?, String) -> Void)?
    static var preHandlers: [Int32: SignalHandler?] = [:]

    // MARK: - Init -

    init(preHandlers: [Int32: SignalHandler?]) {
        Self.preHandlers = preHandlers
    }

}

// MARK: - Extensions -

// MARK: - Preparable conformance

extension CrashSignalExceptionHandler: CrashExceptionPrepareable {

    func prepare() {
        backupOriginalHandler()
        signalNewRegister()
    }

}

// MARK: - Backup

private extension CrashSignalExceptionHandler {

    func backupOriginalHandler() {
        Self.preHandlers.forEach { (signal, handler) in
            var tempHandler = handler
            backupSingleHandler(signal: signal, preHandler: &tempHandler)
        }
    }

    func backupSingleHandler(signal: Int32, preHandler: inout SignalHandler?) {
        let empty: UnsafeMutablePointer<sigaction>? = nil
        var old_action_abrt = sigaction()
        sigaction(signal, empty, &old_action_abrt)

        if old_action_abrt.__sigaction_u.__sa_sigaction != nil {
            preHandler = old_action_abrt.__sigaction_u.__sa_sigaction
        }
    }

}

// MARK: - Signal handling

private extension CrashSignalExceptionHandler {

    func signalNewRegister() {
        register(signal: SIGABRT)
        register(signal: SIGBUS)
        register(signal: SIGFPE)
        register(signal: SIGILL)
        register(signal: SIGPIPE)
        register(signal: SIGSEGV)
        register(signal: SIGSYS)
        register(signal: SIGTRAP)
    }

    func register(signal: Int32) {
        var action = sigaction()
        action.__sigaction_u.__sa_sigaction = crashSignalHandler
        action.sa_flags = SA_NODEFER | SA_SIGINFO
        sigemptyset(&action.sa_mask)
        let empty: UnsafeMutablePointer<sigaction>? = nil
        sigaction(signal, &action, empty)
    }
}

// MARK: - C non capturing functions

private func crashSignalHandler(
    signal: Int32,
    info: UnsafeMutablePointer<__siginfo>?,
    context: UnsafeMutableRawPointer?
) {
    let exceptionInfo = "Signal \(name(for: signal))"

    CrashSignalExceptionHandler.exceptionReceiveClosure?(signal, nil, exceptionInfo)
    clearSignalRegister()

    let handler = CrashSignalExceptionHandler.preHandlers[signal]
    handler??(signal, info, context)
    kill(getpid(), SIGKILL)
}

private func name(for signal: Int32) -> String {
    switch signal {
    case SIGABRT: "SIGABRT"
    case SIGBUS: "SIGBUS"
    case SIGFPE: "SIGFPE"
    case SIGILL: "SIGILL"
    case SIGPIPE: "SIGPIPE"
    case SIGSEGV: "SIGSEGV"
    case SIGSYS: "SIGSYS"
    case SIGTRAP: "SIGTRAP"
    default: "None"
    }
}

private func clearSignalRegister() {
    signal(SIGSEGV, SIG_DFL)
    signal(SIGFPE, SIG_DFL)
    signal(SIGBUS, SIG_DFL)
    signal(SIGTRAP, SIG_DFL)
    signal(SIGABRT, SIG_DFL)
    signal(SIGILL, SIG_DFL)
    signal(SIGPIPE, SIG_DFL)
    signal(SIGSYS, SIG_DFL)
}
