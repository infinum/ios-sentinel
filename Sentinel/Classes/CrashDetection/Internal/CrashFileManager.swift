//
//  CrashFileManager.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

// Inspiration link: https://github.com/DebugSwift/DebugSwift

import Foundation

enum CrashFileManager {

    /// Registers to handle the uncaught crashes and log them
    /// Should be called on app start-up
    static func registerUncaughtExceptionHandler(exceptionReceiveHandler: ((Int32?, NSException?, String) -> Void)?) {
        CrashHandler.shared.registerUncaughtExceptionHandler()
        CrashHandler.shared.registerUncaughtExceptionHandler(exceptionReceiveHandler: exceptionReceiveHandler)
    }

    /// Registers to handle the signal crashes and log them
    /// Should be called on app start-up
    static func registerSignalExceptionHandler(exceptionReceiveHandler: ((Int32?, NSException?, String) -> Void)?) {
        CrashHandler.shared.registerSignalExceptionHandler()
        CrashHandler.shared.registerSignalExceptionHandler(exceptionReceiveHandler: exceptionReceiveHandler)
    }

    static func save(crash: CrashModel) {
        let filePath = getDocumentsDirectory().appendingPathComponent(crash.type.fileName)

        // Try to load existing crashes from file
        var existingCrashes = (try? readCrashModels(from: filePath)) ?? []

        // Append the new crash
        existingCrashes.append(crash)

        // Save the updated crashes array
        do {
            let jsonData = try JSONEncoder().encode(existingCrashes)
            try jsonData.write(to: filePath)
        } catch { }
    }

    static func recover(ofType type: CrashType) -> [CrashModel] {
        let filePath = getDocumentsDirectory().appendingPathComponent(type.fileName)
        return (try? readCrashModels(from: filePath)) ?? []
    }

    static func deleteAll() {
        let nsExceptionPath = getDocumentsDirectory().appendingPathComponent(CrashType.nsexception.fileName)
        let signalPath = getDocumentsDirectory().appendingPathComponent(CrashType.signal.fileName)

        deleteFile(at: nsExceptionPath)
        deleteFile(at: signalPath)
    }

}

private extension CrashFileManager {

    @discardableResult
    static func deleteFile(at url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else { return false }

        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            return false
        }

        return true
    }

    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    static func readCrashModels(from url: URL) throws -> [CrashModel] {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([CrashModel].self, from: data)
    }

}

private extension CrashFileManager {

    @StringBuilder
    static func crashLog(for crashModel: CrashModel) -> String {
        "Crash stack:"
        String.newLine
        "Crash name: \(crashModel.details.name)"
        String.newLine
        "Crash date: \(crashModel.details.date)"
        String.newLine
        crashModel.details.deviceInfo
        String.newLine

        crashModel.traces
            .map(stackTrace(for:))
            .joined(separator: "\n")
    }

    @StringBuilder
    static func stackTrace(for trace: CrashModel.StackTrace) -> String {
        trace.title
        trace.detail
    }

}
