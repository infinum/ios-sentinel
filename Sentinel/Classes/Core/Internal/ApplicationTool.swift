//
//  GeneralInfoTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation
import SwiftUI

/// Tool which shows Plist information about the App
struct ApplicationTool: Tool {

    // MARK: - Public properties

    public var name: String { tool.name }

    // MARK: - Lifecycle

    public init() {}

    // MARK: - Private properties

    private let tool = CustomInfoTool(
        name: "Application",
        info: [
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
            ),
            CustomInfoTool.Section(
                title: "Bundle all info",
                items: bundleAllInfos
            )
        ]
    )
}

// MARK: - Extensions

// MARK: - UI

extension ApplicationTool {

    var toolTable: ToolTable {
        tool.createToolTable(with: tool.info)
    }

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View {
        SentinelListView(title: name, items: toolTable.sections)
    }
    #else
    var content: any View {
        SentinelListView(title: name, items: toolTable.sections)
    }
    #endif
}

// MARK: - Info helpers

extension ApplicationTool {

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
