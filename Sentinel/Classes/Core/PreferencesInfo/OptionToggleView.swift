//
//  OptionToggleView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 27.11.2024..
//

import SwiftUI

struct OptionToggleView: View {

    @State var value: Bool
    let title: String
    let onValueChanged: (Bool) -> Void

    var body: some View {
        Toggle(isOn: $value) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: value) { onValueChanged($0) }
    }
}

// MARK: - Helpers

extension OptionToggleView {

    init(item: ToggleToolItem) {
        value = item.loadStoredValue()
        title = item.title
        onValueChanged = item.change(to:)
    }
}
