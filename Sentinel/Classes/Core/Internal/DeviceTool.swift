//
//  DeviceInfoTool.swift
//
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import Foundation
import UIKit

class DeviceTool: Tool {

    // MARK: - Lifecycle

    public init() {}

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

    // MARK: - Internal properties

    var toolTable: ToolTable {
        return tool.createToolTable(with: tool.info)
    }

    // MARK: - Private properties

    private var systemVersion: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }

    // MARK: - Public properties

    public var name: String { tool.name }

    // MARK: - Public methods

    public func presentPreview(from viewController: UIViewController) {
        tool.presentPreview(from: viewController)
    }
}

// MARK: - Private extension

private extension DeviceTool {

    var batteryState: String {
        switch UIDevice.current.batteryState {
        case .charging:
            return "Charging at: \(calculateBatteryPercentage(with: UIDevice.current.batteryLevel.description))%"
        case .full:
            return "Full"
        case .unplugged:
            return "\(calculateBatteryPercentage(with: UIDevice.current.batteryLevel.description))%"
        default:
            return "Unknown"
        }
    }

    func calculateBatteryPercentage(with amount: String) -> String {
        guard let batteryLevel = Double(amount) else { return "Unknown" }
        return "\(batteryLevel * 100.0)"
    }
}
