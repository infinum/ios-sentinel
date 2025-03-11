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

        CrashUncaughtExceptionHandler.exceptionReceiveClosure = { [weak self] signal, exception, info in
            self?.exceptionReceiveClosure?(signal, exception, info)
            CrashManager.save(
                crash: .init(type: .nsexception, details: .builder(name: info))
            )
        }

        CrashSignalExceptionHandler.exceptionReceiveClosure = { [weak self] signal, exception, info in
            self?.exceptionReceiveClosure?(signal, exception, info)
            CrashManager.save(
                crash: .init(type: .signal, details: .builder(name: info))
            )
        }
    }

}

// MARK: - Extensions -

// MARK: - Preperable conformance

extension CrashHandler: Preperable {

    func prepare() {
        uncaughtExceptionHandler.prepare()
        signalExceptionHandler.prepare()
    }

}
