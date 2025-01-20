//
//  DeviceInfoTool.swift
//
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import SwiftUI
#if canImport(IOKit)
import IOKit
#endif

/// Tool which shows current device information
struct DeviceTool: Tool {

    // MARK: - Public properties

    public var name: String { tool.name }

    // MARK: - Lifecycle

    public init() {}

    // MARK: - Private properties

    private let tool = CustomInfoTool(
        name: "Device",
        info: [section]
    )

}

// MARK: - UI

extension DeviceTool {

    var toolTable: ToolTable {
        tool.createToolTable(with: tool.info)
    }

    var content: any View {
        SentinelListView(title: name, items: toolTable.sections)
    }
}

// MARK: - Info helpers

private extension DeviceTool {

    static var section: CustomInfoTool.Section {
        #if os(macOS)
        CustomInfoTool.Section(title: "Device", items: [
            .init(title: "Model", value: getModelIdentifier() ?? ""),
            .init(title: "Name", value: ProcessInfo.processInfo.hostName),
            .init(title: "System version", value: systemVersion),
            .init(title: "UUID", value: hardwareDeviceUUID ?? "???")
        ])
        #else
        CustomInfoTool.Section(title: "Device", items: [
            .init(title: "Model", value: UIDevice.current.model),
            .init(title: "Name", value: UIDevice.current.name),
            .init(title: "System version", value: systemVersion),
            .init(title: "UUID", value: UIDevice.current.identifierForVendor?.uuidString ?? "???"),
            .init(title: "Battery state", value: batteryState),
            .init(title: "Proximity state", value: UIDevice.current.proximityState ? "Close" : "Far")
        ])
        #endif
    }

    static var systemVersion: String {
        #if os(iOS)
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        #elseif os(macOS)
        "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
        #endif
    }

    static var batteryState: String {
        #if os(macOS)
        "Unknown"
        #else
        switch UIDevice.current.batteryState {
        case .charging:
            "Charging at: \(calculateBatteryPercentage(with: UIDevice.current.batteryLevel.description))%"
        case .full:
            "Full"
        case .unplugged:
            "\(calculateBatteryPercentage(with: UIDevice.current.batteryLevel.description))%"
        default:
            "Unknown"
        }
        #endif
    }

    #if canImport(IOKit)
    static func getModelIdentifier() -> String? {
        fetchIOValue(for: "model")
    }

    static var hardwareDeviceUUID: String? {
        fetchIOValue(for: kIOPlatformUUIDKey)
    }
    #endif

    static func calculateBatteryPercentage(with amount: String) -> String {
        guard let batteryLevel = Double(amount) else { return "Unknown" }
        return "\(batteryLevel * 100.0)"
    }
}

#if os(macOS)
// MARK: - MacOS helpers

private extension DeviceTool {

    static func fetchIOValue(for valueName: String) -> String? {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

        let valueIdentifier: String?
        if let property = IORegistryEntryCreateCFProperty(service, valueName as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
            valueIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
        }

        IOObjectRelease(service)
        return modelIdentifier
    }

}
#endif
