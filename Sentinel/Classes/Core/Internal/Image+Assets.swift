//
//  Image+Assets.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.12.2024..
//

import SwiftUI

// There's an issue with the generated assets, and local cocoapods which should be resolved in Xcode 16.1
extension Image {
    enum SentinelImages{}
}

extension Image.SentinelImages {
    static var device = Image.load(using: "device")
    static var application = Image.load(using: "application")
    static var tools = Image.load(using: "tools")
    static var preferences = Image.load(using: "preferences")
    static var performance = Image.load(using: "performance")
}

extension Image {

    static func load(using name: String) -> Image {
        let frameworkBundle = Bundle(for: Sentinel.self)
        guard let frameworkURL = frameworkBundle.resourceURL else { return .init(systemName: "edit") }
        let bundleURL = frameworkURL.appendingPathComponent("Sentinel.bundle")

        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.sentinel
        #else
        let resourceBundle = Bundle(url: bundleURL)
        #endif

        return Image(name, bundle: resourceBundle)
    }
}
