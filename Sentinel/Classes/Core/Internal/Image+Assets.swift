//
//  Image+Assets.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 16.05.2025..
//

import SwiftUI

extension Image {

    static func image(_ name: String) -> Image {
        Image(name, bundle: .sentinel)
    }
}
