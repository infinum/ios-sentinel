//
//  UncaughtExceptionHandlerTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

// The handlers keep their callbacks in static properties, so these tests can't run in parallel.
@Suite("Crash detection handlers", .serialized)
struct UncaughtExceptionHandlerTests {

    @Test("The uncaught exception handler passes the exception and its info to the callback")
    func uncaughtHandlerReportsException() {
        let previousClosure = CrashUncaughtExceptionHandler.exceptionReceiveClosure
        defer { CrashUncaughtExceptionHandler.exceptionReceiveClosure = previousClosure }
        var received: (signal: Int32?, exception: NSException?, info: String)?
        CrashUncaughtExceptionHandler.exceptionReceiveClosure = { received = ($0, $1, $2) }
        let exception = NSException(name: .invalidArgumentException, reason: "Bad argument")

        UncaughtExceptionHandler(exception: exception)

        #expect(received?.signal == nil)
        #expect(received?.exception === exception)
        // The name and the reason are concatenated without a separator.
        #expect(received?.info == "NSInvalidArgumentExceptionBad argument")
    }

    @Test("An exception without a reason is reported as Unknown")
    func uncaughtHandlerWithoutReason() {
        let previousClosure = CrashUncaughtExceptionHandler.exceptionReceiveClosure
        defer { CrashUncaughtExceptionHandler.exceptionReceiveClosure = previousClosure }
        var info: String?
        CrashUncaughtExceptionHandler.exceptionReceiveClosure = { info = $2 }

        UncaughtExceptionHandler(exception: NSException(name: .genericException, reason: nil))

        #expect(info == "NSGenericExceptionUnknown")
    }

    @Test("Preparing twice still calls the app's handler exactly once")
    func preparingTwiceKeepsAppHandler() {
        let previousHandler = NSGetUncaughtExceptionHandler()
        let previousClosure = CrashUncaughtExceptionHandler.exceptionReceiveClosure
        defer {
            NSSetUncaughtExceptionHandler(previousHandler)
            CrashUncaughtExceptionHandler.exceptionReceiveClosure = previousClosure
        }
        AppHandlerCalls.count = 0
        NSSetUncaughtExceptionHandler { _ in AppHandlerCalls.count += 1 }
        CrashUncaughtExceptionHandler.exceptionReceiveClosure = nil

        CrashUncaughtExceptionHandler(preHandlers: [:]).prepare()
        CrashUncaughtExceptionHandler(preHandlers: [:]).prepare()
        // Before the fix, the second `prepare()` backed up Sentinel's own handler, which then called itself forever.
        UncaughtExceptionHandler(exception: NSException(name: .genericException, reason: nil))

        #expect(AppHandlerCalls.count == 1)
    }

    @Test("The tool installs no handlers when observing is turned off")
    func toolWithoutObserving() {
        let previousHandler = handlerAddress()
        let hadClosure = CrashUncaughtExceptionHandler.exceptionReceiveClosure != nil

        let tool = CrashDetectionTool(
            name: "Crashes",
            shouldObserveUncaughtExceptions: false,
            shouldObserveSignalExceptions: false
        )

        #expect(tool.name == "Crashes")
        #expect(handlerAddress() == previousHandler)
        #expect((CrashUncaughtExceptionHandler.exceptionReceiveClosure != nil) == hadClosure)
    }
}

private extension UncaughtExceptionHandlerTests {

    /// C function pointers aren't Equatable, so compare the installed handler by address.
    func handlerAddress() -> UnsafeRawPointer? {
        unsafeBitCast(NSGetUncaughtExceptionHandler(), to: UnsafeRawPointer?.self)
    }
}

/// Counts calls to the handler a test installs; a C function pointer can't capture a local variable.
private enum AppHandlerCalls {
    static var count = 0
}
