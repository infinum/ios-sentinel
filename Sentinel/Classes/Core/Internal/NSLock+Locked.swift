//
//  NSLock+Locked.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

extension NSLock {

    /// Runs `body` while holding the lock. Foundation's own `withLock` needs iOS 17 and macOS 14.
    func locked<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
