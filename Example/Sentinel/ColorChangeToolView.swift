//
//  ColorChangeToolView.swift
//  Sentinel_Example
//
//  Created by Zvonimir Medak on 13.12.2024..
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct ColorChangeToolView: View {

    @State var isBlue: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            (isBlue ? Color.blue : Color.red)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Change color") { isBlue.toggle() }
        }
    }

}
