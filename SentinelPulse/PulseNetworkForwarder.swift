//
//  PulseNetworkForwarder.swift
//  SentinelPulse
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(iOS)

import Combine
import Foundation
import Pulse
import Sentinel

/// Hands the requests Pulse logs to Sentinel Companion. It records nothing while the app's Mac connection is
/// switched off.
final class PulseNetworkForwarder {

    private static let lock = NSLock()
    private static var forwarders: [ObjectIdentifier: PulseNetworkForwarder] = [:]

    private let subscription: AnyCancellable

    /// Starts forwarding the store's requests. A store is forwarded once, however many tools show it.
    static func start(for store: LoggerStore, to recorder: RemoteNetworkRecorder = .shared) {
        lock.lock()
        defer { lock.unlock() }
        let id = ObjectIdentifier(store)
        guard forwarders[id] == nil else { return }
        forwarders[id] = PulseNetworkForwarder(store: store, recorder: recorder)
    }

    private init(store: LoggerStore, recorder: RemoteNetworkRecorder) {
        // Pulse sends events on the thread that logged them; the recorder takes them from any thread.
        subscription = store.events.sink { event in
            if let entry = RemoteNetworkEntry(event: event) {
                recorder.record(entry)
            }
        }
    }
}

// MARK: - Pulse events

extension RemoteNetworkEntry {

    /// The entry for a request that started or finished, or `nil` for any other event. Progress updates are
    /// left out: the Mac has nothing to show for them.
    init?(event: LoggerStore.Event) {
        switch event {
        case .networkTaskCreated(let task):
            let request = task.currentRequest ?? task.originalRequest
            let requestHeaders = request.headers ?? [:]
            self.init(
                id: task.taskId,
                createdAt: task.createdAt,
                method: request.httpMethod ?? "GET",
                url: request.url?.absoluteString ?? "",
                requestHeaders: requestHeaders,
                isMocked: RemoteNetworkEntry.isMocked(requestHeaders: requestHeaders, responseHeaders: [:])
            )
        case .networkTaskCompleted(let task):
            let request = task.currentRequest ?? task.originalRequest
            let requestHeaders = request.headers ?? [:]
            let responseHeaders = task.response?.headers ?? [:]
            self.init(
                id: task.taskId,
                createdAt: task.createdAt,
                method: request.httpMethod ?? "GET",
                url: request.url?.absoluteString ?? "",
                requestHeaders: requestHeaders,
                requestBody: task.requestBody.map(Body.init(data:)),
                statusCode: task.response?.statusCode,
                responseHeaders: responseHeaders,
                responseBody: task.responseBody.map(Body.init(data:)),
                errorDescription: task.error.map { error in
                    error.error?.localizedDescription ?? error.debugDescription
                },
                duration: task.metrics?.taskInterval.duration ?? Date().timeIntervalSince(task.createdAt),
                isMocked: RemoteNetworkEntry.isMocked(requestHeaders: requestHeaders, responseHeaders: responseHeaders)
            )
        case .messageStored, .networkTaskProgressUpdated:
            return nil
        @unknown default:
            return nil
        }
    }
}

#endif
