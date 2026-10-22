//
//  DeviceInfoProvider+macOS.swift
//  Sentinel
//
//  Created by Karlo Čeh on 22.10.2026..
//

#if os(macOS)
import AppKit

// MARK: - Device

extension DeviceInfoProvider {

    static var deviceSection: CustomInfoTool.Section {
        CustomInfoTool.Section(title: "Device", items: [
            CustomInfoTool.Item(title: "Manufacturer", value: "Apple"),
            CustomInfoTool.Item(title: "Model identifier", value: DeviceTool.getModelIdentifier() ?? unknown),
            CustomInfoTool.Item(title: "Name", value: ProcessInfo.processInfo.hostName),
            CustomInfoTool.Item(title: "System version", value: DeviceTool.systemVersion),
            CustomInfoTool.Item(title: "UUID", value: DeviceTool.hardwareDeviceUUID ?? unknown),
            CustomInfoTool.Item(title: "Architecture", value: architecture)
        ])
    }
}

// MARK: - Screen

extension DeviceInfoProvider {

    static var screenSection: CustomInfoTool.Section {
        guard let screen = NSScreen.main else {
            return CustomInfoTool.Section(title: "Screen", items: [
                CustomInfoTool.Item(title: "Screen size", value: unknown)
            ])
        }

        let scale = screen.backingScaleFactor
        let pixels = CGSize(width: screen.frame.width * scale, height: screen.frame.height * scale)
        return CustomInfoTool.Section(title: "Screen", items: [
            CustomInfoTool.Item(title: "Screen size", value: format(screen.frame.size, unit: "pt")),
            CustomInfoTool.Item(title: "Screen resolution", value: format(pixels, unit: "px")),
            CustomInfoTool.Item(title: "Screen scale", value: String(format: "%gx", scale)),
            CustomInfoTool.Item(title: "Max refresh rate", value: "\(screen.maximumFramesPerSecond) Hz")
        ])
    }
}

// MARK: - Accessibility

extension DeviceInfoProvider {

    static var accessibilitySection: CustomInfoTool.Section {
        let workspace = NSWorkspace.shared
        return CustomInfoTool.Section(title: "Accessibility", items: [
            CustomInfoTool.Item(title: "Appearance", value: appearance),
            CustomInfoTool.Item(title: "VoiceOver", value: workspace.isVoiceOverEnabled.yesNo),
            CustomInfoTool.Item(title: "Reduce Motion", value: workspace.accessibilityDisplayShouldReduceMotion.yesNo),
            CustomInfoTool.Item(title: "Increase Contrast", value: workspace.accessibilityDisplayShouldIncreaseContrast.yesNo)
        ])
    }

    private static var appearance: String {
        switch NSApp?.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .aqua: "Light"
        case .darkAqua: "Dark"
        default: unknown
        }
    }
}
#endif
