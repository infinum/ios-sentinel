//
//  ApplicationInfoProvider.swift
//  Sentinel
//
//  Created by Karlo Čeh on 22.10.2026..
//

import Foundation

/// Gathers the sections shown on the Application tab and in the shared report.
enum ApplicationInfoProvider {

    // MARK: - Internal properties

    /// Everything shown on the Application tab.
    static var sections: [CustomInfoTool.Section] {
        reportSections + [bundleAllInfoSection]
    }

    /// The sections that go into the shared report. The raw `Info.plist` dump is left out, because it is long
    /// and its useful keys are already part of these sections.
    static var reportSections: [CustomInfoTool.Section] {
        [runtimeSection, standardPlistSection]
    }
}

// MARK: - Sections

private extension ApplicationInfoProvider {

    static var runtimeSection: CustomInfoTool.Section {
        var items = [
            CustomInfoTool.Item(title: "App language", value: Bundle.main.preferredLocalizations.first ?? unknown),
            CustomInfoTool.Item(title: "Minimum OS", value: minimumOS),
            CustomInfoTool.Item(title: "Built with", value: builtWith),
            CustomInfoTool.Item(
                title: "Process",
                value: "\(ProcessInfo.processInfo.processName) (\(ProcessInfo.processInfo.processIdentifier))"
            )
        ]

        #if os(iOS)
        if !ProcessInfo.processInfo.isiOSAppOnMac && !ProcessInfo.processInfo.isMacCatalystApp {
            items.append(CustomInfoTool.Item(title: "Distribution", value: distribution))
        }
        #endif

        items.append(CustomInfoTool.Item(title: "Sandbox path", value: NSHomeDirectory()))
        return CustomInfoTool.Section(title: "Runtime", items: items)
    }

    static var standardPlistSection: CustomInfoTool.Section {
        CustomInfoTool.Section(
            title: "Standard Plist Info",
            items: [
                CustomInfoTool.Item(title: "App version", value: stringFromPlist(for: "CFBundleShortVersionString")),
                CustomInfoTool.Item(title: "Build version", value: stringFromPlist(for: kCFBundleVersionKey)),
                CustomInfoTool.Item(title: "Bundle name", value: stringFromPlist(for: kCFBundleNameKey)),
                CustomInfoTool.Item(title: "Executable name", value: stringFromPlist(for: kCFBundleExecutableKey)),
                CustomInfoTool.Item(title: "Bundle id", value: stringFromPlist(for: kCFBundleIdentifierKey)),
                CustomInfoTool.Item(title: "Localizations", value: stringFromPlist(for: kCFBundleLocalizationsKey)),
                CustomInfoTool.Item(title: "Development region", value: stringFromPlist(for: kCFBundleDevelopmentRegionKey)),
                CustomInfoTool.Item(title: "Version of the plist", value: stringFromPlist(for: kCFBundleInfoDictionaryVersionKey)),
            ]
        )
    }

    static var bundleAllInfoSection: CustomInfoTool.Section {
        CustomInfoTool.Section(title: "Bundle all info", items: bundleAllInfos)
    }
}

// MARK: - Runtime helpers

private extension ApplicationInfoProvider {

    static let unknown = DeviceInfoProvider.unknown

    static var minimumOS: String {
        #if os(macOS)
        let value = stringFromPlist(for: "LSMinimumSystemVersion")
        #else
        let value = stringFromPlist(for: "MinimumOSVersion")
        #endif
        return value.isEmpty ? unknown : value
    }

    /// `DTXcode` is the less readable `1610`, so the build number such as `16B40` is used.
    static var builtWith: String {
        let sdk = stringFromPlist(for: "DTSDKName")
        let build = stringFromPlist(for: "DTXcodeBuild")
        switch (sdk.isEmpty, build.isEmpty) {
        case (true, true): return unknown
        case (false, true): return sdk
        case (true, false): return "Xcode build \(build)"
        case (false, false): return "\(sdk), Xcode build \(build)"
        }
    }

    #if os(iOS)
    static var distribution: String {
        #if targetEnvironment(simulator)
        return "Simulator"
        #else
        if Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision") != nil {
            return "Development, Ad Hoc or Enterprise"
        }

        // TODO: Replace the receipt check with `AppTransaction.environment` once the minimum is iOS 16.
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
            return "TestFlight"
        }
        return "App Store"
        #endif
    }
    #endif
}

// MARK: - Info.plist helpers

private extension ApplicationInfoProvider {

    static func stringFromPlist(for key: CFString) -> String {
        stringFromPlist(for: key as String)
    }

    static func stringFromPlist(for key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key).map { String(describing: $0) } ?? ""
    }

    static var bundleAllInfos: [CustomInfoTool.Item] {
        Bundle.main.infoDictionary?
            .map { CustomInfoTool.Item(title: $0.key, value: String(describing: $0.value)) }
            ?? []
    }
}
