//
//  CrashUncaughtExceptionHandler.swift
//  MasterConnect
//
//  Created by Zvonimir Medak on 29.04.2024..
//  Copyright © 2024 Signify. All rights reserved.
//

// Inspiration link: https://github.com/DebugSwift/DebugSwift

import Foundation

private var preUncaughtExceptionHandler: NSUncaughtExceptionHandler?

class CrashUncaughtExceptionHandler {
    static var exceptionReceiveClosure: ((Int32?, NSException?, String) -> Void)?

    let preHandlers: [Int32: SignalHandler?]

    init(preHandlers: [Int32: SignalHandler?]) {
        self.preHandlers = preHandlers
    }

    func prepare() {
        preUncaughtExceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(UncaughtExceptionHandler)
    }
}

func UncaughtExceptionHandler(exception: NSException) {
    let reason = exception.reason ?? "Unknown"
    let exceptionInfo = exception.name.rawValue + reason
    CrashUncaughtExceptionHandler.exceptionReceiveClosure?(nil, exception, exceptionInfo)
    preUncaughtExceptionHandler?(exception)
}
