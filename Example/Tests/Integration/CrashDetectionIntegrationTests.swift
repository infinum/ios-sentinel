//
//  CrashDetectionIntegrationTests.swift
//  Sentinel_Tests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Darwin
import Foundation
import Testing
@testable import Sentinel

extension IntegrationTests {

    @Suite("Crash files")
    final class CrashFileManagerTests {

        init() {
            CrashFileManager.deleteAll()
        }

        deinit {
            CrashFileManager.deleteAll()
        }

        @Test("A saved crash is recovered by its type only")
        func saveAndRecover() {
            CrashFileManager.save(crash: makeCrash(type: .signal, name: "SIGABRT"))

            #expect(CrashFileManager.recover(ofType: .signal).map(\.details.name) == ["SIGABRT"])
            #expect(CrashFileManager.recover(ofType: .nsexception).isEmpty)
        }

        @Test("Saving appends to the existing crashes")
        func saveAppends() {
            CrashFileManager.save(crash: makeCrash(type: .nsexception, name: "first"))
            CrashFileManager.save(crash: makeCrash(type: .nsexception, name: "second"))

            #expect(CrashFileManager.recover(ofType: .nsexception).map(\.details.name) == ["first", "second"])
        }

        @Test("deleteAll removes the crashes of every type")
        func deleteAll() {
            CrashFileManager.save(crash: makeCrash(type: .nsexception, name: "exception"))
            CrashFileManager.save(crash: makeCrash(type: .signal, name: "signal"))

            CrashFileManager.deleteAll()

            #expect(CrashFileManager.recover(ofType: .nsexception).isEmpty)
            #expect(CrashFileManager.recover(ofType: .signal).isEmpty)
        }

        @Test("Without a custom handler, an uncaught exception is saved as a crash")
        func uncaughtExceptionIsSaved() {
            let previousClosure = CrashUncaughtExceptionHandler.exceptionReceiveClosure
            defer { CrashUncaughtExceptionHandler.exceptionReceiveClosure = previousClosure }

            CrashHandler.shared.registerUncaughtExceptionHandler(exceptionReceiveHandler: nil)
            UncaughtExceptionHandler(exception: NSException(name: .genericException, reason: "Boom"))

            #expect(CrashFileManager.recover(ofType: .nsexception).map(\.details.name) == ["NSGenericExceptionBoom"])
        }

        @Test("A custom handler replaces saving the crash")
        func customHandlerReplacesSaving() {
            let previousClosure = CrashSignalExceptionHandler.exceptionReceiveClosure
            defer { CrashSignalExceptionHandler.exceptionReceiveClosure = previousClosure }
            var received: String?

            CrashHandler.shared.registerSignalExceptionHandler(exceptionReceiveHandler: { received = $2 })
            CrashSignalExceptionHandler.exceptionReceiveClosure?(SIGABRT, nil, "Signal SIGABRT")

            #expect(received == "Signal SIGABRT")
            #expect(CrashFileManager.recover(ofType: .signal).isEmpty)
        }

        private func makeCrash(type: CrashType, name: String) -> CrashModel {
            CrashModel(
                type: type,
                details: CrashModel.Details.builder(name: name),
                traces: [CrashModel.StackTrace(title: "frame", detail: "")]
            )
        }
    }

    @Suite("Signal handlers")
    struct SignalHandlerTests {

        // Every signal Sentinel registers. Their original actions are restored after each test.
        private static let handledSignals = [SIGABRT, SIGBUS, SIGFPE, SIGILL, SIGPIPE, SIGSEGV, SIGSYS, SIGTRAP]

        @Test("A handler installed before Sentinel is kept so it can still be called")
        func previousHandlerIsBackedUp() {
            let originalActions = Self.handledSignals.map { signal -> sigaction in
                var action = sigaction()
                sigaction(
                    signal,
                    nil,
                    &action
                )
                return action
            }
            let previousPreHandlers = CrashSignalExceptionHandler.preHandlers
            defer {
                for (signal, originalAction) in zip(Self.handledSignals, originalActions) {
                    var action = originalAction
                    sigaction(
                        signal,
                        &action,
                        nil
                    )
                }
                CrashSignalExceptionHandler.preHandlers = previousPreHandlers
            }

            // A no-op handler for SIGPIPE, which is in Sentinel's list and harmless. Nothing raises it.
            var appHandler = sigaction()
            appHandler.__sigaction_u.__sa_sigaction = { _, _, _ in }
            appHandler.sa_flags = SA_SIGINFO
            sigemptyset(&appHandler.sa_mask)
            sigaction(
                SIGPIPE,
                &appHandler,
                nil
            )

            CrashSignalExceptionHandler(preHandlers: SignalPrehandlerManager().preHandlers).prepare()

            #expect(CrashSignalExceptionHandler.preHandlers.keys.sorted() == Self.handledSignals.sorted())
            withKnownIssue("backupSingleHandler writes into a temporary copy, so the previous handler is never stored") {
                #expect(CrashSignalExceptionHandler.preHandlers[SIGPIPE] ?? nil != nil)
            }
        }
    }
}
