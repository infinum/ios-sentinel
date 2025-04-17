//
//  PreferencesPickerView.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import SwiftUI

struct PreferencesPickerView: View {

    @State private var selectedOption: String
    @State private var errorMessage: String?
    let title: String
    let description: String?
    let values: [any PickerValue]
    let onValueChanged: (any PickerValue) -> Void
    let hasErrorMessage: (any PickerValue) -> String?

    var body: some View {
        VStack(spacing: 8) {
            Picker(selection: $selectedOption) {
                ForEach(values.map(\.description), id: \.self) { option in
                    Text(option)
                }
            } label: {
                Text(title)
                    .font(.body1Bold)
            }

            DescriptionView(description: description, errorMessage: errorMessage)
        }
        .onChange(of: selectedOption) { value in
            guard let currentValue = values.first(where: { $0.description == value }) else { return }
            guard let message = hasErrorMessage(currentValue) else {
                errorMessage = nil
                onValueChanged(currentValue)
                return
            }
            errorMessage = message
        }
    }
}

extension PreferencesPickerView {

    init(item: PreferencesPickerItem) {
        selectedOption = item.getter().description
        title = item.name
        values = item.values
        onValueChanged = item.change
        description = item.description
        hasErrorMessage = item.lastErrorMessageIfInvalid
    }
}
