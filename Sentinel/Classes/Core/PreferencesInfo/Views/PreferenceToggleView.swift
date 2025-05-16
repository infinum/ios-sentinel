//
//  PreferenceToggleView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 27.11.2024..
//

import SwiftUI

struct PreferenceToggleView: View {

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
                    .font(.body1Bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            DescriptionView(description: description, errorMessage: errorMessage)
        }
        .onChange(of: value, perform: handleValueChange)
        .onAppear { value = getter() }
    }
}

// MARK: - Helpers

// MARK: - Init

extension PreferenceToggleView {

    init(item: PreferenceToggleItem) {
        value = item.getter()
        title = item.name
        onValueChanged = item.change(to:)
        getter = item.getter
        description = item.description
        hasErrorMessage = item.lastErrorMessageIfInvalid
    }
}

extension PreferenceToggleView {

    func handleValueChange(_ value: Bool) {
        guard let message = hasErrorMessage(value) else {
            errorMessage = nil
            onValueChanged(value)
            return
        }
        errorMessage = message
    }
}
