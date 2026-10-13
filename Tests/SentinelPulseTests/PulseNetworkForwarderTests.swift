//
//  PulseNetworkForwarderTests.swift
//  SentinelPulseTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(iOS)
import Foundation
import Pulse
import Sentinel
import Testing
@testable import SentinelPulse

@Suite("Pulse requests for Sentinel for Mac")
struct PulseNetworkForwarderTests {

    private let taskID = UUID()
    private let createdAt = Date(timeIntervalSinceReferenceDate: 100)

    @Test("A started request becomes an entry still in flight")
    func created() throws {
        let event = LoggerStore.Event.networkTaskCreated(
            LoggerStore.Event.NetworkTaskCreated(
                taskId: taskID,
                taskType: .dataTask,
                createdAt: createdAt,
                originalRequest: request(headers: ["Accept": "application/json"]),
                currentRequest: nil,
                label: nil,
                taskDescription: nil
            )
        )

        let entry = try #require(RemoteNetworkEntry(event: event))

        #expect(entry.id == taskID)
        #expect(entry.method == "POST")
        #expect(entry.url == "https://example.com/products")
        #expect(entry.requestHeaders == ["Accept": "application/json"])
        #expect(!entry.isCompleted)
        #expect(!entry.isMocked)
    }

    @Test("A finished request carries its response, bodies and duration")
    func completed() throws {
        let entry = try #require(RemoteNetworkEntry(event: completedEvent(requestHeaders: [:], responseBody: Data("[]".utf8))))

        #expect(entry.statusCode == 200)
        #expect(entry.responseHeaders == ["Content-Type": "application/json"])
        #expect(entry.requestBody?.data == Data("{}".utf8))
        #expect(entry.responseBody?.data == Data("[]".utf8))
        #expect(entry.isCompleted)
    }

    @Test("A request an API mock answered is marked mocked")
    func mocked() throws {
        let event = completedEvent(requestHeaders: ["X-PulseRequestMocked": "true"], responseBody: nil)

        #expect(try #require(RemoteNetworkEntry(event: event)).isMocked)
    }

    @Test("A large response body is cut off")
    func truncated() throws {
        let event = completedEvent(requestHeaders: [:], responseBody: Data(count: RemoteNetworkEntry.maximumBodySize * 2))

        let body = try #require(RemoteNetworkEntry(event: event)?.responseBody)

        #expect(body.isTruncated)
        #expect(body.size == RemoteNetworkEntry.maximumBodySize * 2)
    }

    @Test("Progress updates and log messages aren't forwarded")
    func otherEvents() {
        let progress = LoggerStore.Event.networkTaskProgressUpdated(
            LoggerStore.Event.NetworkTaskProgressUpdated(taskId: taskID, url: nil, completedUnitCount: 1, totalUnitCount: 2)
        )

        #expect(RemoteNetworkEntry(event: progress) == nil)
    }

    private func request(headers: [String: String]) -> NetworkLogger.Request {
        var urlRequest = URLRequest(url: URL(string: "https://example.com/products")!)
        urlRequest.httpMethod = "POST"
        headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        return NetworkLogger.Request(urlRequest)
    }

    private func completedEvent(requestHeaders: [String: String], responseBody: Data?) -> LoggerStore.Event {
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com/products")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return LoggerStore.Event.networkTaskCompleted(
            LoggerStore.Event.NetworkTaskCompleted(
                taskId: taskID,
                taskType: .dataTask,
                createdAt: createdAt,
                originalRequest: request(headers: requestHeaders),
                currentRequest: nil,
                response: NetworkLogger.Response(response),
                error: nil,
                requestBody: Data("{}".utf8),
                responseBody: responseBody,
                metrics: nil,
                label: nil,
                taskDescription: nil
            )
        )
    }
}
#endif
