//
//  DeviceSession.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(iOS)

import Foundation
import Network
import UIKit

/// The app's connection to Sentinel Companion: finds Macs, connects to the one the user picks, and comes back
/// to it while the connection is switched on. Used from the main thread.
final class DeviceSession: ObservableObject {

    struct DiscoveredMac: Identifiable, Equatable {
        let name: String
        let endpoint: NWEndpoint
        var id: String { name }
    }

    enum Status: Equatable {
        case off
        case searching
        case connecting(macName: String)
        case pairing(code: String, macName: String)
        case connected(macName: String)
        case failed(String)
    }

    static let shared = DeviceSession(store: MacConnectionStore(fileURL: MacConnectionStore.defaultFileURL))

    /// How long to wait before connecting again after a connection drops.
    private static let reconnectDelay: TimeInterval = 3

    @Published private(set) var isEnabled: Bool
    @Published private(set) var status = Status.off
    @Published private(set) var macs: [DiscoveredMac] = []
    /// The listed Mac the app connects to, whose name may differ from the one the Mac gives itself.
    @Published private(set) var selectedMac: DiscoveredMac?

    private let store: MacConnectionStore
    private let recorder: RemoteNetworkRecorder
    private var isSearching = false
    private var browser: NWBrowser?
    private var connection: RemoteConnection?
    private var mockBridge: RemoteMockBridge?
    /// Off after a pairing is turned down, so the app doesn't keep asking until the user picks a Mac again.
    private var reconnectsAutomatically = true
    private var reconnectWorkItem: DispatchWorkItem?
    private var activeObserver: NSObjectProtocol?

    // MARK: - Lifecycle

    init(store: MacConnectionStore, recorder: RemoteNetworkRecorder = .shared) {
        self.store = store
        self.recorder = recorder
        isEnabled = store.isEnabled
        activeObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // iOS drops the connection while the app is suspended.
            self?.reconnectIfNeeded()
        }
    }

    /// Resumes the connection when it was left on. The app asked for local network access when the user
    /// switched it on, so searching at launch doesn't prompt.
    func activate() {
        if isEnabled {
            recorder.setRecording(true)
            startSearching()
        }
    }

    func setEnabled(_ isEnabled: Bool) {
        store.isEnabled = isEnabled
        self.isEnabled = isEnabled
        recorder.setRecording(isEnabled)
        if isEnabled {
            reconnectsAutomatically = true
            startSearching()
        } else {
            stop()
        }
    }

    func connect(to mac: DiscoveredMac) {
        reconnectWorkItem?.cancel()
        reconnectsAutomatically = true
        store.lastMacName = mac.name
        connection?.cancel()

        let connection = RemoteConnection(
            connection: NWConnection(to: mac.endpoint, using: RemoteService.makeParameters()),
            role: .device(RemoteDeviceInfo.current(id: store.deviceID), pairedMacIDs: store.pairedPeerIDs),
            keyStore: store
        )
        connection.onEvent = { [weak self, weak connection] event in
            // Events of a connection that was replaced or stopped don't matter any more.
            guard let self, let connection, connection === self.connection else { return }
            handle(event)
        }
        self.connection = connection
        selectedMac = mac
        status = .connecting(macName: mac.name)
        connection.start()
    }

    func confirmPairing() {
        connection?.confirmPairing()
    }

    func rejectPairing() {
        connection?.rejectPairing()
    }
}

// MARK: - Info.plist

extension DeviceSession {

    /// The Info.plist entries searching for Macs needs that the app lacks.
    static var missingInfoPlistEntries: [String] {
        var missing: [String] = []
        if Bundle.main.object(forInfoDictionaryKey: "NSLocalNetworkUsageDescription") == nil {
            missing.append("NSLocalNetworkUsageDescription")
        }
        let services = Bundle.main.object(forInfoDictionaryKey: "NSBonjourServices") as? [String] ?? []
        if !services.contains(RemoteService.type) {
            missing.append("NSBonjourServices containing \(RemoteService.type)")
        }
        return missing
    }
}

// MARK: - Searching

private extension DeviceSession {

    func startSearching() {
        guard !isSearching else { return }
        isSearching = true
        status = .searching
        #if targetEnvironment(simulator)
        // The Simulator shares the Mac's network, so the Mac is on localhost, no Bonjour needed.
        update(
            [
                DiscoveredMac(
                    name: "This Mac",
                    endpoint: NWEndpoint.hostPort(host: "127.0.0.1", port: RemoteService.preferredPort)
                )
            ]
        )
        #else
        let browser = NWBrowser(
            for: NWBrowser.Descriptor.bonjour(type: RemoteService.type, domain: nil),
            using: RemoteService.makeParameters()
        )
        browser.browseResultsChangedHandler = { [weak self] results, _ in
            self?.update(results.compactMap(DiscoveredMac.init(result:)))
        }
        browser.stateUpdateHandler = { [weak self] state in
            self?.handle(state)
        }
        browser.start(queue: .main)
        self.browser = browser
        #endif
    }

    func stop() {
        reconnectWorkItem?.cancel()
        browser?.cancel()
        browser = nil
        isSearching = false
        connection?.cancel()
        connection = nil
        mockBridge = nil
        recorder.stopForwarding()
        selectedMac = nil
        macs = []
        status = .off
    }

    func handle(_ state: NWBrowser.State) {
        switch state {
        case .waiting(let error), .failed(let error):
            guard connection == nil else { return }
            if case .dns(let code) = error, code == DNSServiceErrorType(kDNSServiceErr_PolicyDenied) {
                status = .failed("The app isn't allowed to use the local network. Allow it in Settings › Privacy & Security › Local Network.")
            } else {
                status = .failed(error.localizedDescription)
            }
        default:
            break
        }
    }

    func update(_ discoveredMacs: [DiscoveredMac]) {
        macs = Self.listed(discoveredMacs)
        reconnectIfNeeded()
    }

    /// Connects to the last Mac again when it's around and nothing else is going on.
    func reconnectIfNeeded() {
        guard isEnabled, reconnectsAutomatically, connection == nil,
              let mac = macs.first(where: { $0.name == store.lastMacName })
        else { return }
        connect(to: mac)
    }

    func scheduleReconnect() {
        reconnectWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.reconnectIfNeeded()
        }
        reconnectWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.reconnectDelay, execute: workItem)
    }
}

// MARK: - Connection events

private extension DeviceSession {

    func handle(_ event: RemoteConnection.Event) {
        switch event {
        case .pairingCode(let code, let mac):
            status = .pairing(code: code, macName: mac.name)
        case .connected(let mac):
            status = .connected(macName: mac.name)
            mockBridge = RemoteMockBridge(store: APIMockStore.shared) { [weak connection] message in
                connection?.send(message)
            }
            recorder.startForwarding { [weak connection] entry in
                connection?.send(RemoteMessage.networkEntry(entry), isDroppable: true)
            }
        case .message(.mockCommand(let command)):
            mockBridge?.apply(command)
        case .message:
            break
        case .closed(let reason):
            connection = nil
            mockBridge = nil
            recorder.stopForwarding()
            status = .failed(reason.message)
            if reason.allowsReconnect {
                scheduleReconnect()
            } else {
                reconnectsAutomatically = false
            }
        }
    }
}

// MARK: - Browse results

extension DeviceSession {

    /// The Macs to list: each once, as a Mac reachable over several links, such as Wi-Fi and peer-to-peer
    /// Wi-Fi, shows up once per link, sorted by name.
    static func listed(_ discoveredMacs: [DiscoveredMac]) -> [DiscoveredMac] {
        var names = Set<String>()
        return discoveredMacs
            .filter { names.insert($0.name).inserted }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

private extension DeviceSession.DiscoveredMac {

    init?(result: NWBrowser.Result) {
        guard case .service(let name, _, _, _) = result.endpoint else { return nil }
        self.init(name: name, endpoint: result.endpoint)
    }
}

#endif
