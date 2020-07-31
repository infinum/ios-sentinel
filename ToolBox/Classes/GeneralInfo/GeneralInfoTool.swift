//
//  GeneralInfoTool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

public class GeneralInfoTool: Tool {
    
    public init() {}
    
    private(set) lazy var tool = CustomInfoTool(
        name: "General Info",
        info: [
            CustomInfoTool.Section(
                title: "Standard Plist Info",
                items: [
                    .init(title: "App version", value: stringFromPlist(for: "CFBundleShortVersionString")),
                    .init(title: "Build version", value: stringFromPlist(for: kCFBundleVersionKey)),
                    .init(title: "Bundle name", value: stringFromPlist(for: kCFBundleNameKey)),
                    .init(title: "Executable name", value: stringFromPlist(for: kCFBundleExecutableKey)),
                    .init(title: "Bundle id", value: stringFromPlist(for: kCFBundleIdentifierKey)),
                    .init(title: "Localizations", value: stringFromPlist(for: kCFBundleLocalizationsKey)),
                    .init(title: "Development region", value: stringFromPlist(for: kCFBundleDevelopmentRegionKey)),
                    .init(title: "Version of the plist", value: stringFromPlist(for: kCFBundleInfoDictionaryVersionKey)),
                ]
            ),
            CustomInfoTool.Section(
                title: "Bundle all info",
                items: bundleAllInfos
            )
        ]
    )
    
    public var name: String { tool.name }
    public func presentPreview(from viewController: UIViewController) {
        tool.presentPreview(from: viewController)
    }
}

extension GeneralInfoTool {
    
    func stringFromPlist(for key: CFString) -> String {
        stringFromPlist(for: key as String)
    }
    
    func stringFromPlist(for key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key).map { String(describing: $0) } ?? ""
    }
    
    var bundleAllInfos: [CustomInfoTool.Item] {
        Bundle.main.infoDictionary?
            .map { CustomInfoTool.Item(title: $0.key, value: String(describing: $0.value)) }
            ?? []
    }
    
}
