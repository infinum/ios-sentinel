//
//  MacConnectionStore.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import CryptoKit
import Foundation

/// The device's side of the Mac connection that outlives a launch: its id, whether the connection is on,
/// the last Mac it connected to, and the pairing keys.
///
/// Kept in a file next to the API mocks rather than in the Keychain or user defaults, both of which
/// `ClearAppDataTool` wipes, so a reset of the app doesn't mean pairing again.
final class MacConnectionStore: RemotePairingKeyStore {

    fileprivate struct State: Codable {
        var deviceID = UUID().uuidString
        var isEnabled = false
        var lastMacName: String?
        var keys: [String: Data] = [:]
    }

    /// Next to `APIMocking.json`, in the folder `ClearAppDataTool` leaves alone.
    static var defaultFileURL: URL {
        APIMockPersistence.defaultFileURL
            .deletingLastPathComponent()
            .appendingPathComponent("MacConnection.json")
    }

    private let fileURL: URL
    private let lock = NSLock()
    private var state: State

    init(fileURL: URL) {
        self.fileURL = fileURL
        if let data = try? Data(contentsOf: fileURL), let state = try? JSONDecoder().decode(State.self, from: data) {
            self.state = state
        } else {
            state = State()
            write()
        }
    }

    var deviceID: String {
        lock.locked { state.deviceID }
    }

    var isEnabled: Bool {
        get { lock.locked { state.isEnabled } }
        set { update { $0.isEnabled = newValue } }
    }

    var lastMacName: String? {
        get { lock.locked { state.lastMacName } }
        set { update { $0.lastMacName = newValue } }
    }

    /// The Macs the device has a pairing key for.
    var pairedPeerIDs: [String] {
        lock.locked { state.keys.keys.sorted() }
    }

    // MARK: - RemotePairingKeyStore

    func key(forPeer id: String) -> SymmetricKey? {
        lock.locked { state.keys[id].map { SymmetricKey(data: $0) } }
    }

    func save(_ key: SymmetricKey, forPeer id: String) {
        update { $0.keys[id] = key.withUnsafeBytes { Data($0) } }
    }

    func removeKey(forPeer id: String) {
        update { $0.keys[id] = nil }
    }
}

// MARK: - Helpers

private extension MacConnectionStore {

    /// Writes while holding the lock, so two quick changes can't reach the file in the wrong order.
    func update(_ change: (inout State) -> Void) {
        lock.locked {
            change(&state)
            write()
        }
    }

    func write() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            #if os(iOS)
            let options: Data.WritingOptions = [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
            #else
            let options: Data.WritingOptions = [.atomic]
            #endif
            try JSONEncoder().encode(state).write(to: fileURL, options: options)
        } catch {
            NSLog("Sentinel couldn't save %@: %@", fileURL.path, "\(error)")
        }
    }
}
