//
//  DeviceInfoProvider.swift
//  Sentinel
//
//  Created by Karlo Čeh on 22.10.2026..
//

import Foundation

/// Gathers the sections shown on the Device tab and in the shared report.
enum DeviceInfoProvider {

    // MARK: - Internal properties

    static var sections: [CustomInfoTool.Section] {
        [deviceSection, powerSection, screenSection, localeSection, accessibilitySection]
    }
}

// MARK: - Shared helpers

extension DeviceInfoProvider {

    static let unknown = "Unknown"

    static var architecture: String {
        #if arch(arm64)
        "arm64"
        #elseif arch(x86_64)
        "x86_64"
        #else
        unknown
        #endif
    }

    static var thermalState: String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: "Nominal"
        case .fair: "Fair"
        case .serious: "Serious"
        case .critical: "Critical"
        @unknown default: unknown
        }
    }

    /// Formats a size as `393 × 852 pt`.
    static func format(_ size: CGSize, unit: String) -> String {
        String(format: "%g × %g %@", size.width, size.height, unit)
    }
}

extension Bool {

    var yesNo: String {
        self ? "Yes" : "No"
    }
}

// MARK: - Power

extension DeviceInfoProvider {

    static var powerSection: CustomInfoTool.Section {
        CustomInfoTool.Section(title: "Power", items: powerItems)
    }

    private static var powerItems: [CustomInfoTool.Item] {
        var items = [CustomInfoTool.Item]()
        #if os(iOS)
        items.append(CustomInfoTool.Item(title: "Battery state", value: batteryState))
        #endif
        items.append(CustomInfoTool.Item(title: "Low Power Mode", value: ProcessInfo.processInfo.isLowPowerModeEnabled.yesNo))
        items.append(CustomInfoTool.Item(title: "Thermal state", value: thermalState))
        return items
    }
}

// MARK: - Locale

extension DeviceInfoProvider {

    static var localeSection: CustomInfoTool.Section {
        let locale = Locale.current
        return CustomInfoTool.Section(title: "Locale", items: [
            CustomInfoTool.Item(title: "Locale identifier", value: locale.identifier),
            CustomInfoTool.Item(title: "Language", value: languageCode(of: locale) ?? unknown),
            CustomInfoTool.Item(title: "Region", value: regionCode(of: locale) ?? unknown),
            CustomInfoTool.Item(title: "Preferred languages", value: Locale.preferredLanguages.joined(separator: ", ")),
            CustomInfoTool.Item(title: "Time zone", value: timeZone),
            CustomInfoTool.Item(title: "Calendar", value: String(describing: locale.calendar.identifier)),
            CustomInfoTool.Item(title: "Currency", value: currencyCode(of: locale) ?? unknown),
            CustomInfoTool.Item(title: "Measurement system", value: measurementSystem(of: locale)),
            CustomInfoTool.Item(title: "24-hour time", value: uses24HourTime(locale: locale).yesNo)
        ])
    }

    private static func languageCode(of locale: Locale) -> String? {
        #if os(macOS)
        locale.language.languageCode?.identifier
        #else
        if #available(iOS 16, *) {
            locale.language.languageCode?.identifier
        } else {
            locale.languageCode
        }
        #endif
    }

    private static func regionCode(of locale: Locale) -> String? {
        #if os(macOS)
        locale.region?.identifier
        #else
        if #available(iOS 16, *) {
            locale.region?.identifier
        } else {
            locale.regionCode
        }
        #endif
    }

    private static func currencyCode(of locale: Locale) -> String? {
        #if os(macOS)
        locale.currency?.identifier
        #else
        if #available(iOS 16, *) {
            locale.currency?.identifier
        } else {
            locale.currencyCode
        }
        #endif
    }

    private static func measurementSystem(of locale: Locale) -> String {
        #if os(macOS)
        name(of: locale.measurementSystem)
        #else
        if #available(iOS 16, *) {
            name(of: locale.measurementSystem)
        } else {
            locale.usesMetricSystem ? "Metric" : "Imperial"
        }
        #endif
    }

    @available(iOS 16, macOS 13, *)
    private static func name(of system: Locale.MeasurementSystem) -> String {
        switch system {
        case .metric: "Metric"
        case .us: "US"
        case .uk: "UK"
        default: unknown
        }
    }

    private static var timeZone: String {
        let timeZone = TimeZone.current
        let offset = timeZone.secondsFromGMT()
        let sign = offset < 0 ? "-" : "+"
        let hours = abs(offset) / 3600
        let minutes = abs(offset) % 3600 / 60
        return String(format: "%@ (GMT%@%02d:%02d)", timeZone.identifier, sign, hours, minutes)
    }

    private static func uses24HourTime(locale: Locale) -> Bool {
        let format = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale) ?? ""
        return !format.contains("a")
    }
}
