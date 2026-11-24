//
//  APIMockMatcher.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Finds the mock that answers a request.
///
/// The URL loading system asks from its own threads, so the matcher keeps the active mocks behind a lock
/// and never touches the store: a request that arrives before the tool is set up costs nothing.
final class APIMockMatcher: @unchecked Sendable {

    static let shared = APIMockMatcher()

    private struct CompiledMock {
        let mock: APIMock
        let expression: NSRegularExpression
    }

    private let lock = NSLock()
    private var mocks: [CompiledMock] = []

    /// Replaces the mocks that answer requests, in the order they're tried.
    func update(activeMocks: [APIMock]) {
        let compiled = activeMocks.compactMap { mock in
            mock.url.makeRegularExpression().map { CompiledMock(mock: mock, expression: $0) }
        }
        lock.lock()
        mocks = compiled
        lock.unlock()
    }

    func mock(for request: URLRequest) -> APIMock? {
        guard let url = request.url, ["http", "https"].contains(url.scheme?.lowercased()) else { return nil }

        lock.lock()
        let mocks = self.mocks
        lock.unlock()
        guard !mocks.isEmpty else { return nil }

        let method = (request.httpMethod ?? "GET").uppercased()
        let urlString = url.absoluteString
        let range = NSRange(urlString.startIndex..., in: urlString)
        return mocks.first { compiled in
            if let mockMethod = compiled.mock.method, mockMethod.rawValue != method {
                return false
            }
            return compiled.expression.firstMatch(in: urlString, range: range) != nil
        }?.mock
    }
}
