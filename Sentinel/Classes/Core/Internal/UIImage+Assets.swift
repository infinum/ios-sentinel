//
//  UIImage+Assets.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 15.11.2021..
//

import Foundation

extension UIImage {
    enum SentinelImages{}
}

extension UIImage.SentinelImages {
    static var device = UIImage.loadImageFromBundle(name: "device")
    static var application = UIImage.loadImageFromBundle(name: "application")
    static var tools = UIImage.loadImageFromBundle(name: "tools")
    static var preferences = UIImage.loadImageFromBundle(name: "preferences")
    static var performance = UIImage.loadImageFromBundle(name: "performance")
}
