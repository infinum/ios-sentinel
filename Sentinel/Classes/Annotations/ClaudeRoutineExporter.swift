//
//  ClaudeRoutineExporter.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import Foundation

/// Fires a Claude Code routine, sending the annotation JSON as an extra turn appended to the
/// routine's session.
///
/// `token` supplies a Claude Code OAuth token, used as a bearer token. It is a closure rather
/// than a string so an app can read it from an xcconfig, the environment or a development-only
/// source instead of hardcoding a credential that ships inside the app binary. `fireUrl` is the
/// routine's fire endpoint, for example
/// `https://api.anthropic.com/v1/claude_code/routines/<trigger-id>/fire`.
///
/// - Warning: Treat the token as a secret. It is a long-lived credential carrying the
/// developer's full permissions, and anyone holding the app binary can extract a value compiled
/// into it. Never commit one.
public struct ClaudeRoutineExporter: AnnotationExporter {

    // MARK: - Private properties

    private enum Constants {
        static let anthropicVersion = "2023-06-01"
        static let anthropicBeta = "experimental-cc-routine-2026-04-01"
        static let successRange = 200...299
    }

    private let token: @Sendable () -> String?
    private let fireUrl: String
    private let poster: HTTPPoster

    // MARK: - Public properties

    public let iconSystemName = "paperplane"

    public let label = "Send to Claude"

    // MARK: - Lifecycle

    /// - Parameters:
    ///     - token: Supplies the Claude Code OAuth token. Return `nil` to refuse the export.
    ///     - fireUrl: The routine's fire endpoint.
    public init(token: @escaping @Sendable () -> String?, fireUrl: String) {
        self.init(token: token, fireUrl: fireUrl, poster: URLSessionHTTPPoster())
    }

    init(token: @escaping @Sendable () -> String?, fireUrl: String, poster: HTTPPoster) {
        self.token = token
        self.fireUrl = fireUrl
        self.poster = poster
    }

    // MARK: - Public methods

    public func export(_ annotations: [SentinelAnnotation]) async throws -> String {
        let count = try await send(annotations)
        return "Sent \(count) annotations"
    }

    // MARK: - Internal methods

    /// Posts `annotations` and returns how many were sent.
    ///
    /// Refuses with ``AnnotationExportError/missingToken`` rather than firing an unauthenticated
    /// request, so a missing credential reads as a configuration problem and not as a rejection
    /// from the endpoint.
    func send(_ annotations: [SentinelAnnotation]) async throws -> Int {
        guard let bearer = token(), !bearer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AnnotationExportError.missingToken
        }

        let payload = try SentinelAnnotation.exportJSON(for: annotations)
        let body = try JSONSerialization.data(withJSONObject: ["text": payload], options: [])
        guard let bodyString = String(data: body, encoding: .utf8) else {
            throw AnnotationExportError.encodingFailed
        }

        let response = try await poster.post(
            url: fireUrl,
            headers: [
                "Authorization": "Bearer \(bearer)",
                "anthropic-version": Constants.anthropicVersion,
                "anthropic-beta": Constants.anthropicBeta,
                "Content-Type": "application/json"
            ],
            body: bodyString
        )

        guard Constants.successRange.contains(response.statusCode) else {
            throw AnnotationExportError.requestFailed(statusCode: response.statusCode, body: response.body)
        }

        return annotations.count
    }
}

#endif
