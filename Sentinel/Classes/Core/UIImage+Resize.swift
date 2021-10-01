//
//  UIImage+Resize.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 30.09.2021..
//

import Foundation
extension UIImage {
    func resize(for size: CGSize = CGSize(width: 24, height: 24)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

