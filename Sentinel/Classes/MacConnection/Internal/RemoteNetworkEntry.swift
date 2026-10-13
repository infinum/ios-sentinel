//
//  RemoteNetworkEntry.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// A request the app made, as Sentinel for Mac shows it. Sent once when the request starts and again,
/// complete, when it finishes; the Mac replaces the first with the second.
///
/// It doesn't depend on where it was recorded, so sources other than Pulse can produce it too.
package struct RemoteNetworkEntry: Codable, Equatable, Identifiable, Sendable {

    package struct Body: Codable, Equatable, Sendable {

        /// The body, cut off at ``RemoteNetworkEntry/maximumBodySize``.
        package var data: Data
        /// Size of the whole body in bytes.
        package var size: Int

        package var isTruncated: Bool {
            data.count < size
        }

        package init(data: Data) {
            size = data.count
            self.data = Data(data.prefix(RemoteNetworkEntry.maximumBodySize))
        }
    }

    /// Longer bodies are cut off, so one large download doesn't hold up everything else on the connection.
    package static let maximumBodySize = 1024 * 1024

    package var id: UUID
    package var createdAt: Date
    package var method: String
    package var url: String
    package var requestHeaders: [String: String]
    package var requestBody: Body?
    package var statusCode: Int?
    package var responseHeaders: [String: String]
    package var responseBody: Body?
    package var errorDescription: String?
    /// Seconds the request took, or `nil` while it's in flight.
    package var duration: TimeInterval?
    /// `true` when an API mock answered the request.
    package var isMocked: Bool

    package var isCompleted: Bool {
        duration != nil
    }

    package init(
        id: UUID,
        createdAt: Date,
        method: String,
        url: String,
        requestHeaders: [String: String],
        requestBody: Body? = nil,
        statusCode: Int? = nil,
        responseHeaders: [String: String] = [:],
        responseBody: Body? = nil,
        errorDescription: String? = nil,
        duration: TimeInterval? = nil,
        isMocked: Bool
    ) {
        self.id = id
        self.createdAt = createdAt
        self.method = method
        self.url = url
        self.requestHeaders = requestHeaders
        self.requestBody = requestBody
        self.statusCode = statusCode
        self.responseHeaders = responseHeaders
        self.responseBody = responseBody
        self.errorDescription = errorDescription
        self.duration = duration
        self.isMocked = isMocked
    }

    /// Roughly the bytes the entry takes, to keep the buffered entries within a budget.
    var approximateSize: Int {
        let headers = (requestHeaders.merging(responseHeaders) { first, _ in first })
            .reduce(0) { $0 + $1.key.utf8.count + $1.value.utf8.count }
        return url.utf8.count + headers + (requestBody?.data.count ?? 0) + (responseBody?.data.count ?? 0)
    }
}

// MARK: - Mocked requests

package extension RemoteNetworkEntry {

    /// Whether the headers show that an API mock answered: the marker Pulse looks for on the request, or the
    /// mock's name on the response.
    static func isMocked(requestHeaders: [String: String], responseHeaders: [String: String]) -> Bool {
        requestHeaders.keys.contains { $0.caseInsensitiveCompare(APIMockingURLProtocol.pulseMockedHeaderName) == .orderedSame }
            || responseHeaders.keys.contains { $0.caseInsensitiveCompare(APIMockingURLProtocol.mockHeaderName) == .orderedSame }
    }
}
