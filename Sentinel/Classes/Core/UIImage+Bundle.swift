//
//  UIImage+Bundle.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import UIKit

extension UIImage {

    static func load(fromBundleNamed name: String) -> UIImage? {
        let frameworkBundle = Bundle(for: Sentinel.self)
        guard let frameworkURL = frameworkBundle.resourceURL else { return nil }
        let bundleURL = frameworkURL.appendingPathComponent("Sentinel.bundle")

        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.sentinel
        #else
        let resourceBundle = Bundle(url: bundleURL)
        #endif
        
        return UIImage(named: name, in: resourceBundle, compatibleWith: nil)
    }
}

