//
//  DeviceInfoProvider+iOS.swift
//  Sentinel
//
//  Created by Karlo Čeh on 22.10.2026..
//

#if os(iOS)
import UIKit

// MARK: - Device

extension DeviceInfoProvider {

    static var deviceSection: CustomInfoTool.Section {
        CustomInfoTool.Section(title: "Device", items: [
            CustomInfoTool.Item(title: "Manufacturer", value: "Apple"),
            CustomInfoTool.Item(title: "Model identifier", value: modelIdentifier ?? unknown),
            CustomInfoTool.Item(title: "Name", value: UIDevice.current.name),
            CustomInfoTool.Item(title: "System version", value: DeviceTool.systemVersion),
            CustomInfoTool.Item(title: "UUID", value: UIDevice.current.identifierForVendor?.uuidString ?? unknown),
            CustomInfoTool.Item(title: "Architecture", value: architecture),
            CustomInfoTool.Item(title: "Simulator", value: isSimulator.yesNo),
            CustomInfoTool.Item(title: "Runs on", value: runsOn)
        ])
    }

    private static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    private static var modelIdentifier: String? {
        #if targetEnvironment(simulator)
        ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = systemInfo.machine
        return withUnsafeBytes(of: machine) {
            $0.bindMemory(to: CChar.self).baseAddress.map { String(cString: $0) }
        }
        #endif
    }

    private static var runsOn: String {
        if ProcessInfo.processInfo.isiOSAppOnMac || ProcessInfo.processInfo.isMacCatalystApp {
            return "Mac"
        }

        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return "iPhone"
        case .pad: return "iPad"
        case .tv: return "Apple TV"
        case .carPlay: return "CarPlay"
        case .mac: return "Mac"
        case .vision: return "Apple Vision"
        default: return unknown
        }
    }
}

// MARK: - Power

extension DeviceInfoProvider {

    /// Battery monitoring is process-wide state that the host app may manage itself,
    /// so it is only enabled while the value is read and then restored.
    static var batteryState: String {
        let device = UIDevice.current
        let wasMonitoringEnabled = device.isBatteryMonitoringEnabled
        device.isBatteryMonitoringEnabled = true
        defer { device.isBatteryMonitoringEnabled = wasMonitoringEnabled }

        let state = device.batteryState
        let level = device.batteryLevel
        guard level >= 0 else { return unknown }

        let percentage = Int((level * 100).rounded())
        switch state {
        case .charging: return "Charging at \(percentage)%"
        case .full: return "Full"
        case .unplugged: return "\(percentage)%"
        default: return unknown
        }
    }
}

// MARK: - Screen

extension DeviceInfoProvider {

    static var screenSection: CustomInfoTool.Section {
        let scene = foregroundWindowScene
        let screen = scene?.screen ?? .main
        let window = scene?.keyWindow

        var items = [
            CustomInfoTool.Item(title: "Screen size", value: format(screen.bounds.size, unit: "pt")),
            CustomInfoTool.Item(title: "Screen resolution", value: format(screen.nativeBounds.size, unit: "px")),
            CustomInfoTool.Item(title: "Screen scale", value: String(format: "%gx", screen.scale)),
            CustomInfoTool.Item(title: "Max refresh rate", value: "\(screen.maximumFramesPerSecond) Hz")
        ]

        if let window {
            let insets = window.safeAreaInsets
            items.append(CustomInfoTool.Item(title: "Window size", value: format(window.bounds.size, unit: "pt")))
            items.append(CustomInfoTool.Item(
                title: "Safe area insets",
                value: String(
                    format: "top %g, left %g, bottom %g, right %g",
                    insets.top, insets.left, insets.bottom, insets.right
                )
            ))
        }

        if let scene {
            items.append(CustomInfoTool.Item(title: "Orientation", value: orientation(of: scene.interfaceOrientation)))
        }

        return CustomInfoTool.Section(title: "Screen", items: items)
    }

    /// The scene the user is looking at, or any scene when none is in the foreground.
    private static var foregroundWindowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    private static func orientation(of orientation: UIInterfaceOrientation) -> String {
        switch orientation {
        case .portrait: "Portrait"
        case .portraitUpsideDown: "Portrait upside down"
        case .landscapeLeft: "Landscape left"
        case .landscapeRight: "Landscape right"
        default: unknown
        }
    }
}

// MARK: - Accessibility

extension DeviceInfoProvider {

    static var accessibilitySection: CustomInfoTool.Section {
        CustomInfoTool.Section(title: "Accessibility", items: [
            CustomInfoTool.Item(title: "Text size", value: textSize),
            CustomInfoTool.Item(title: "Appearance", value: appearance),
            CustomInfoTool.Item(title: "VoiceOver", value: UIAccessibility.isVoiceOverRunning.yesNo),
            CustomInfoTool.Item(title: "Reduce Motion", value: UIAccessibility.isReduceMotionEnabled.yesNo),
            CustomInfoTool.Item(title: "Increase Contrast", value: UIAccessibility.isDarkerSystemColorsEnabled.yesNo),
            CustomInfoTool.Item(title: "Bold Text", value: UIAccessibility.isBoldTextEnabled.yesNo)
        ])
    }

    /// `UIContentSizeCategory` raw values look like `UICTContentSizeCategoryL`.
    private static var textSize: String {
        UIApplication.shared.preferredContentSizeCategory.rawValue
            .replacingOccurrences(of: "UICTContentSizeCategory", with: String.empty)
    }

    /// Read from the scene rather than the window, so a style the app forces on its window doesn't hide the device setting.
    private static var appearance: String {
        switch foregroundWindowScene?.traitCollection.userInterfaceStyle {
        case .light: "Light"
        case .dark: "Dark"
        default: unknown
        }
    }
}
#endif
