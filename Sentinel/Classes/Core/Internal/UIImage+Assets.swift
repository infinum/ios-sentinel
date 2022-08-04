//
//  UIImage+Assets.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 15.11.2021..
//

import UIKit

extension UIImage {
    enum SentinelImages{}
}

extension UIImage.SentinelImages {
    static var device = UIImage.load(fromBundleNamed: "device")
    static var application = UIImage.load(fromBundleNamed: "application")
    static var tools = UIImage.load(fromBundleNamed: "tools")
    static var preferences = UIImage.load(fromBundleNamed: "preferences")
    static var performance = UIImage.load(fromBundleNamed: "performance")
}
