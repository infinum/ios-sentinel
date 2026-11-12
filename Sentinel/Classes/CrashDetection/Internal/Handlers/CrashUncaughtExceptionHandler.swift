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
        let installedHandler = NSGetUncaughtExceptionHandler()
        let sentinelHandler: @convention(c) (NSException) -> Void = UncaughtExceptionHandler
        // When `prepare()` runs more than once, the installed handler is Sentinel's own. Backing it up
        // would make the handler call itself, so keep the one backed up the first time.
        let installedAddress = unsafeBitCast(installedHandler, to: UnsafeRawPointer?.self)
        let sentinelAddress = unsafeBitCast(sentinelHandler, to: UnsafeRawPointer.self)
        if installedAddress != sentinelAddress {
            preUncaughtExceptionHandler = installedHandler
        }
        NSSetUncaughtExceptionHandler(UncaughtExceptionHandler)
    }
}

func UncaughtExceptionHandler(exception: NSException) {
    let reason = exception.reason ?? "Unknown"
    let exceptionInfo = exception.name.rawValue + reason
    CrashUncaughtExceptionHandler.exceptionReceiveClosure?(nil, exception, exceptionInfo)
    preUncaughtExceptionHandler?(exception)
}
