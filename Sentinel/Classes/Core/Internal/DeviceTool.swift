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

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View  {
        SentinelListView(title: name, items: toolTable.sections)
    }
    #else
    var content: any View {
        SentinelListView(title: name, items: toolTable.sections)
    }
    #endif
}

// MARK: - Info helpers

private extension DeviceTool {

    static var section: CustomInfoTool.Section {
        #if os(macOS)
        macOSSection
        #else
        iOSSection
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
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

        var valueIdentifier: String?
        let property = IORegistryEntryCreateCFProperty(service, valueName as CFString, kCFAllocatorDefault, 0).takeRetainedValue()

        if let property = property as? Data {
            valueIdentifier = String(data: property, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
        } else if let property = property as? String {
            valueIdentifier = property
        }

        IOObjectRelease(service)
        return valueIdentifier
    }

    static var macOSSection: CustomInfoTool.Section {
        CustomInfoTool.Section(title: "Device", items: [
            CustomInfoTool.Item(title: "Model", value: getModelIdentifier() ?? ""),
            CustomInfoTool.Item(title: "Name", value: ProcessInfo.processInfo.hostName),
            CustomInfoTool.Item(title: "System version", value: systemVersion),
            CustomInfoTool.Item(title: "UUID", value: hardwareDeviceUUID ?? "???")
        ])
    }
}
#else

private extension DeviceTool {

    static var iOSSection: CustomInfoTool.Section {
        CustomInfoTool.Section(title: "Device", items: [
            CustomInfoTool.Item(title: "Model", value: UIDevice.current.model),
            CustomInfoTool.Item(title: "Name", value: UIDevice.current.name),
            CustomInfoTool.Item(title: "System version", value: systemVersion),
            CustomInfoTool.Item(title: "UUID", value: UIDevice.current.identifierForVendor?.uuidString ?? "???"),
            CustomInfoTool.Item(title: "Battery state", value: batteryState),
            CustomInfoTool.Item(title: "Proximity state", value: UIDevice.current.proximityState ? "Close" : "Far")
        ])
    }
}
#endif

extension DeviceTool {

    struct Info: Codable, CustomStringConvertible {
        let model: String
        let name: String
        let systemVersion: String
        let UUID: String

        #if os(macOS)
        init() {
            model = DeviceTool.getModelIdentifier() ?? ""
            name = ProcessInfo.processInfo.hostName
            systemVersion = DeviceTool.systemVersion
            UUID = DeviceTool.hardwareDeviceUUID
        }
        #else
        init() {
            model = UIDevice.current.model
            name = UIDevice.current.name
            systemVersion = DeviceTool.systemVersion
            UUID = UIDevice.current.identifierForVendor?.uuidString ?? "???"
        }
        #endif

        @StringBuilder
        var description: String {
            "Manufacturer: Apple"
            String.newLine
            "Device model: \(model)"
            String.newLine
            "Device OS: \(systemVersion)"
            String.newLine
            "Device ID: \(UUID)"
            String.newLine
        }
    }
}
