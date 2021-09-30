//
//  DeviceInfoTool.swift
//
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import Foundation
import UIKit

public class DeviceInfoTool: Tool {

    // MARK: -Lifecycle

    public init() {}

    // MARK: - Private properties

    private(set) lazy var tool = CustomInfoTool(
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

    private var systemVersion: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }

    // MARK: - Public properties

    public var name: String { tool.name }

    // MARK: - Public methods

    public func presentPreview(from viewController: UIViewController) {
        tool.presentPreview(from: viewController)
    }

    public func createViewController(on viewController: UIViewController? = nil) -> UIViewController {
        let controller = tool.createViewController()
        controller.tabBarItem = UITabBarItem(title: "Device", image: nil, tag: 0)
        return controller
    }
}

// MARK: - Private methods

private extension DeviceInfoTool {

    var batteryState: String {
        switch UIDevice.current.batteryState {
        case .charging:
            return "Charging at: \(UIDevice.current.batteryLevel.description)%"
        case .full:
            return "Full"
        case .unplugged:
            return "\(UIDevice.current.batteryLevel.description)%"
        default:
            return "Unknown"
        }
    }
}
