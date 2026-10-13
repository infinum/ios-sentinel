//
//  RemoteNetworkRecorder.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Collects the app's requests for Sentinel Companion. It keeps the latest ones, so a Mac that connects sees
/// what happened just before, and forwards each new one while a Mac is connected.
///
/// Requests are recorded from whichever thread logs them, so everything happens behind a lock.
package final class RemoteNetworkRecorder: @unchecked Sendable {

    package static let shared = RemoteNetworkRecorder()

    /// The budget for the kept requests, in bytes. The oldest go first.
    private let maximumSize: Int
    private let lock = NSLock()
    private var isRecording = false
    private var entries: [RemoteNetworkEntry] = []
    private var size = 0
    private var forward: ((RemoteNetworkEntry) -> Void)?

    package init(maximumSize: Int = 8 * 1024 * 1024) {
        self.maximumSize = maximumSize
    }

    /// Keeps the request, replacing an earlier entry for it, and forwards it to a connected Mac.
    /// Does nothing while the Mac connection is switched off.
    package func record(_ entry: RemoteNetworkEntry) {
        lock.locked {
            guard isRecording else { return }
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                size -= entries[index].approximateSize
                entries.remove(at: index)
            }
            entries.append(entry)
            size += entry.approximateSize
            while size > maximumSize, entries.count > 1 {
                size -= entries.removeFirst().approximateSize
            }
            // Forwarded under the lock, so requests reach the Mac in the order they were recorded.
            forward?(entry)
        }
    }

    package var recordedEntries: [RemoteNetworkEntry] {
        lock.locked { entries }
    }
}

// MARK: - Device session

package extension RemoteNetworkRecorder {

    func setRecording(_ isRecording: Bool) {
        lock.locked {
            self.isRecording = isRecording
            if !isRecording {
                entries = []
                size = 0
                forward = nil
            }
        }
    }

    /// Hands every kept request to `forward`, then each new one until ``stopForwarding()``. `forward` is
    /// called under the lock, so it must not block.
    func startForwarding(to forward: @escaping (RemoteNetworkEntry) -> Void) {
        lock.locked {
            self.forward = forward
            entries.forEach(forward)
        }
    }

    func stopForwarding() {
        lock.locked {
            forward = nil
        }
    }
}
