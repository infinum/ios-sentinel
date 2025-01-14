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

    /// Tries to load an image with the provided name. Defaults to nil if the Image is not available
    /// - Parameters:
    ///     - name: Name of the image which will be fetched
    static func load(using name: String) -> Image? {
        let frameworkBundle = Bundle(for: Sentinel.self)
        guard let frameworkURL = frameworkBundle.resourceURL else { return nil }
        return fetchImage(using: name, with: frameworkURL)
    }

    /// Tries to load an image with the provided name. If the image is not available, the app will default to the provided image.
    /// - Parameters:
    ///     - name: Name of the image which will be fetched
    ///     - image: Image which the function will default to if the Image with the provided name wasn not found
    static func load(using name: String, defaultTo image: Image = .init(systemName: "circle.fill")) -> Image {
        let frameworkBundle = Bundle(for: Sentinel.self)
        guard let frameworkURL = frameworkBundle.resourceURL else { return image }
        return fetchImage(using: name, with: frameworkURL)
    }
}

private extension Image {

    static func fetchImage(using name: String, with frameworkURL: URL) -> Image {
        let bundleURL = frameworkURL.appendingPathComponent("Sentinel.bundle")

        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.sentinel
        #else
        let resourceBundle = Bundle(url: bundleURL)
        #endif

        return Image(name, bundle: resourceBundle)
    }
}

