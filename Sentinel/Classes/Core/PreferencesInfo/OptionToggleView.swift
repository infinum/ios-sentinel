//
//  OptionToggleView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 27.11.2024..
//

import SwiftUI

struct OptionToggleView: View {

    @State private var value: Bool
    let title: String
    let onValueChanged: (Bool) -> Void
    let getter: () -> Bool

    var body: some View {
        Toggle(isOn: $value) {
            Text(title)
                .font(.body2Bold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: value) { onValueChanged($0) }
        .onAppear {
            let fetchedValue = getter()
            guard fetchedValue != value else { return }
            value = fetchedValue
        }
    }
}

// MARK: - Helpers

extension OptionToggleView {

    init(item: ToggleToolItem) {
        value = item.loadStoredValue()
        title = item.title
        onValueChanged = item.change(to:)
        getter = item.loadStoredValue
    }
}
