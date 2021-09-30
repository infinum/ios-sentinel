//
//  UIImage+Resize.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import Foundation
extension UIImage {
    static func loadFromBundle(name: String, size: CGSize = CGSize(width: 24, height: 24)) -> UIImage? {
        let bundle = Bundle(for: Sentinel.self)
        guard let image = UIImage(named: name, in: bundle, compatibleWith: nil) else { return nil }
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

