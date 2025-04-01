//
//  CrashHandler.swift
//  MasterConnect
//
//  Created by Zvonimir Medak on 11.04.2024..
//  Copyright © 2024 Signify. All rights reserved.
//

// Inspiration link: https://github.com/DebugSwift/DebugSwift

import Foundation

final class CrashHandler {

    // MARK: - Singleton -

    static let shared = CrashHandler()

    // MARK: - Private properties -

    private let uncaughtExceptionHandler: CrashUncaughtExceptionHandler
    private let signalExceptionHandler: CrashSignalExceptionHandler
    private var exceptionReceiveClosure: ((Int32?, NSException?, String) -> Void)?

    // MARK: - Init -

    init() {
        let signalHandler = SignalPrehandlerManager()
        uncaughtExceptionHandler = CrashUncaughtExceptionHandler(preHandlers: signalHandler.preHandlers)
        signalExceptionHandler = CrashSignalExceptionHandler(preHandlers: signalHandler.preHandlers)
    }

}

// MARK: - Extensions -

// MARK: - Register handlers

extension CrashHandler {

    func registerUncaughtExceptionHandler() {
        uncaughtExceptionHandler.prepare()
    }

    func registerSignalExceptionHandler() {
        signalExceptionHandler.prepare()
    }

}

// MARK: - Register completions for handlers

extension CrashHandler {

    func registerUncaughtExceptionHandler(exceptionReceiveHandler: ((Int32?, NSException?, String) -> Void)?) {
        CrashUncaughtExceptionHandler.exceptionReceiveClosure = { [weak self] signal, exception, info in
            self?.exceptionReceiveClosure?(signal, exception, info)
            guard let exceptionReceiveHandler else {
                CrashFileManager.save(crash: .init(type: .nsexception, details: .builder(name: info)))
                return
            }
            exceptionReceiveHandler(signal, exception, info)
        }
    }

    func registerSignalExceptionHandler(exceptionReceiveHandler: ((Int32?, NSException?, String) -> Void)?) {
        CrashSignalExceptionHandler.exceptionReceiveClosure = { [weak self] signal, exception, info in
            self?.exceptionReceiveClosure?(signal, exception, info)
            guard let exceptionReceiveHandler else {
                CrashFileManager.save(crash: .init(type: .signal, details: .builder(name: info)))
                return
            }
            exceptionReceiveHandler(signal, exception, info)
        }
    }
}
