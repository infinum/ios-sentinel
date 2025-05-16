//
//  Image+Assets.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 16.05.2025..
//

import SwiftUI

extension Image {

    static func image(_ name: String) -> Image? {
        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.sentinel
        #else
        guard let bundleURL = Bundle(for: Sentinel.self).resourceURL?.appendingPathComponent("Sentinel.bundle") else {
            assertionFailure("Failed to fetch the Sentinel bundle URL")
            return nil
        }
        let resourceBundle = Bundle(url: bundleURL)
        #endif

        return Image(name, bundle: resourceBundle)
    }
}
