//
//  HTTPPoster.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import Foundation

struct HTTPResponse: Sendable {
    let statusCode: Int
    let body: String
}

/// Minimal POST seam. Exists so ``ClaudeRoutineExporter`` can be exercised without a network,
/// and so Sentinel needs no HTTP client dependency.
protocol HTTPPoster: Sendable {
    func post(url: String, headers: [String: String], body: String) async throws -> HTTPResponse
}

/// `@unchecked Sendable`: `session` is assigned once during `init` and never again, and
/// `URLSession` is documented as safe to use from any thread. It cannot be a `let` because the
/// session needs `self` as its delegate, which is only available after `super.init()`.
final class URLSessionHTTPPoster: NSObject, HTTPPoster, @unchecked Sendable {

    // MARK: - Private properties

    private enum Constants {
        static let requestTimeout: TimeInterval = 30
    }

    private var session: URLSession!

    // MARK: - Lifecycle

    /// A session of its own, with this object as its delegate, so redirects can be refused.
    ///
    /// `URLSession` re-sends every header across a redirect, so a redirecting fire URL would
    /// hand the bearer token to whatever host the redirect names. The 3xx status is surfaced
    /// as the response instead.
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = Constants.requestTimeout
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    // MARK: - Internal methods

    func post(url: String, headers: [String: String], body: String) async throws -> HTTPResponse {
        guard let requestURL = URL(string: url) else {
            throw AnnotationExportError.invalidURL(url)
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.httpBody = Data(body.utf8)
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        // The completion-handler API rather than `URLSession.data(for:)`, which is iOS 15+ while
        // Sentinel still supports iOS 14.
        return try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let responseBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                continuation.resume(returning: HTTPResponse(statusCode: statusCode, body: responseBody))
            }
            task.resume()
        }
    }
}

// MARK: - URLSessionTaskDelegate

extension URLSessionHTTPPoster: URLSessionTaskDelegate {

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}

#endif
