//
//  DeviceInfoTool.swift
//
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import Foundation
import SwiftUI

/// Tool which shows current device information
struct DeviceTool: Tool {

    // MARK: - Public properties

    public var name: String { tool.name }

    // MARK: - Lifecycle -

    public init() {}

    // MARK: - Private properties -

    private let tool = CustomInfoTool(
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

// MARK: - Extensions -

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

    static var systemVersion: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }

    static var batteryState: String {
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

    static func calculateBatteryPercentage(with amount: String) -> String {
        guard let batteryLevel = Double(amount) else { return "Unknown" }
        return "\(batteryLevel * 100.0)"
    }
}
