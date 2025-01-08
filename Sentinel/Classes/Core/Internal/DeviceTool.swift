//
//  DeviceInfoTool.swift
//
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import SwiftUI

final class DeviceTool: Tool {

    // MARK: - Public properties

    public var name: String { tool.name }

    // MARK: - Lifecycle

    public init() {}

    // MARK: - Internal properties

    var toolTable: ToolTable {
        tool.createToolTable(with: tool.info)
    }

    var content: any View {
        SentinelListView(title: name, items: toolTable.sections)
    }

    // MARK: - Private properties

    private lazy var tool = CustomInfoTool(
        name: "Device",
        info: [
            CustomInfoTool.Section(title: "Device", items: [
                .init(title: "Model", value: UIDevice.current.model),
                .init(title: "Name", value: UIDevice.current.name),
                .init(title: "System version", value: systemVersion),
                .init(title: "UUID", value: UIDevice.current.identifierForVendor?.uuidString ?? "???"),
                .init(title: "Battery state", value: batteryState),
                .init(title: "Proximity state", value: UIDevice.current.proximityState ? "Close" : "Far")
            ])
        ])

}

// MARK: - Extensions

// MARK: - Helpers

private extension DeviceTool {

    var systemVersion: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }

    var batteryState: String {
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
    }

    func calculateBatteryPercentage(with amount: String) -> String {
        guard let batteryLevel = Double(amount) else { return "Unknown" }
        return "\(batteryLevel * 100.0)"
    }
}
