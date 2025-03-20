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
    let description: String?
    let onValueChanged: (Bool) -> Void
    let getter: () -> Bool

    var body: some View {
        VStack(spacing: 8) {
            Toggle(isOn: $value) {
                Text(title)
                    .font(.body2Bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let description {
                Text(description)
                    .font(.caption1Regular)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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
        value = item.getter()
        title = item.name
        onValueChanged = item.change(to:)
        getter = item.getter
        description = item.description
    }
}
