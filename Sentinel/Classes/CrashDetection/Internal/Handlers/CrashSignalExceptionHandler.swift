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
        for signal in Array(Self.preHandlers.keys) {
            Self.preHandlers[signal] = installedHandler(for: signal)
        }
    }

    /// The handler installed for `signal` before Sentinel's, if there is one worth calling.
    func installedHandler(for signal: Int32) -> SignalHandler? {
        let empty: UnsafeMutablePointer<sigaction>? = nil
        var installedAction = sigaction()
        sigaction(signal, empty, &installedAction)

        // A handler set with `sa_handler` shares this union slot. It is still safe to call with three
        // arguments, because the C calling convention ignores the extra ones.
        guard let handler = installedAction.__sigaction_u.__sa_sigaction else { return nil }
        // SIG_IGN isn't a function, and backing up Sentinel's own handler, when `prepare()` runs more than
        // once, would make the crash handler call itself.
        let sentinelHandler: CSignalHandler = crashSignalHandler
        let address = unsafeBitCast(handler, to: UnsafeRawPointer.self)
        guard
            address != unsafeBitCast(SIG_IGN, to: UnsafeRawPointer.self),
            address != unsafeBitCast(sentinelHandler, to: UnsafeRawPointer.self)
        else { return nil }
        return handler
    }

}

// MARK: - Signal handling

private typealias CSignalHandler = @convention(c) (Int32, UnsafeMutablePointer<__siginfo>?, UnsafeMutableRawPointer?) -> Void

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
