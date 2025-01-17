//
//  ColorChangeToolTableItem.swift
//  Sentinel_Example
//
//  Created by Zvonimir Medak on 13.12.2024..
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Sentinel
import SwiftUI

struct ColorChangeToolTableItem: CustomToolTableItem {

    var title: String {
        "Color change"
    }

    var content: any View {
        ColorChangeToolView()
    }
}
