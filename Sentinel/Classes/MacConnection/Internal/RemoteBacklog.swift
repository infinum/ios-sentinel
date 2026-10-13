//
//  RemoteBacklog.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Counts the bytes a connection handed to the network that haven't gone out yet, and decides which
/// droppable messages to leave out while there are too many.
struct RemoteBacklog {

    static let defaultLimit = 4 * 1024 * 1024

    let limit: Int
    private(set) var size = 0
    private var droppedCount = 0

    init(limit: Int) {
        self.limit = limit
    }

    /// What to send for `message`: nothing when it's left out, and otherwise the message, after a count of
    /// the ones left out since the last that went.
    mutating func messages(for message: RemoteMessage, isDroppable: Bool) -> [RemoteMessage] {
        guard isDroppable else { return [message] }
        guard size < limit else {
            droppedCount += 1
            return []
        }
        defer { droppedCount = 0 }
        return droppedCount > 0 ? [RemoteMessage.droppedNetworkEntries(droppedCount), message] : [message]
    }

    mutating func add(_ bytes: Int) {
        size += bytes
    }

    mutating func remove(_ bytes: Int) {
        size -= bytes
    }
}
