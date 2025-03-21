//
//  OptionToggleView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 27.11.2024..
//

import SwiftUI

struct OptionToggleView: View {

    @State private var value: Bool
    @State private var errorMessage: String?
    let title: String
    let description: String?
    let onValueChanged: (Bool) -> Void
    let getter: () -> Bool
    let hasErrorMessage: (Bool) -> String?

    var body: some View {
        VStack(spacing: 8) {
            Toggle(isOn: $value) {
                Text(title)
                    .font(.body2Bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            DescriptionView(description: description, errorMessage: errorMessage)
        }
        .onChange(of: value) { value in
            guard let message = hasErrorMessage(value) else {
                errorMessage = nil
                onValueChanged(value)
                return
            }
            errorMessage = message
        }
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
        hasErrorMessage = item.lastErrorMessageIfInvalid
    }
}
