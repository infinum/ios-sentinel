//
//  UIImage+Resize.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import Foundation
extension UIImage {

    static func loadImageFromBundle(name: String) -> UIImage? {
        let frameworkBundle = Bundle(for: Sentinel.self)
        guard let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("Sentinel.bundle")
        else { return nil }
        let resourceBundle = Bundle(url: bundleURL)
        guard let image = UIImage(named: name, in: resourceBundle, compatibleWith: nil) else {return nil}
        return image
    }

    static func resize(for size: CGSize = CGSize(width: 24, height: 24), _ image: UIImage?) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image?.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

