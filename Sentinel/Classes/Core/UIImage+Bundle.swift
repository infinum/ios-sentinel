//
//  UIImage+Bundle.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import Foundation
extension UIImage {

    static func loadImageFromBundle(name: String) -> UIImage? {
        let frameworkBundle = Bundle(for: Sentinel.self)
        guard let frameworkURL = frameworkBundle.resourceURL else { return nil }
        let bundleURL = frameworkURL.appendingPathComponent("Sentinel.bundle")
        let resourceBundle = Bundle(url: bundleURL)
        return UIImage(named: name, in: resourceBundle, compatibleWith: nil)
    }
}

