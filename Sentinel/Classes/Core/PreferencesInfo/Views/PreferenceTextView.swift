//
//  PreferenceTextView.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import SwiftUI

struct PreferenceTextView: View {

    @State private var value: String
    @State private var errorMessage: String?
    let title: String
    let description: String?
    let onValueChanged: (String) -> Void
    let getter: () -> String
    let hasErrorMessage: (String) -> String?

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.body2Bold)
                TextEditor(text: $value)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .border(.gray, width: 1)
            }

            DescriptionView(description: description, errorMessage: errorMessage)
        }
        .onChange(of: value) { value in
            guard let message = hasErrorMessage(value) else {
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

extension PreferenceTextView {

    init(item: PreferencesTextItem) {
        value = item.getter()
        title = item.name
        onValueChanged = item.change(to:)
        getter = item.getter
        description = item.description
        hasErrorMessage = item.lastErrorMessageIfInvalid
    }

    init(item: PreferencesIntItem) {
        value = String(describing: item.getter())
        title = item.name
        onValueChanged = {
            guard let value = Int($0) else { return }
            item.change(to: value)
        }
        getter = { String(describing: item.getter()) }
        description = item.description
        hasErrorMessage = {
            guard let value = Int($0) else { return "Invalid value" }
            return item.lastErrorMessageIfInvalid(value: value)
        }
    }

    init(item: PreferencesFloatItem) {
        value = String(describing: item.getter())
        title = item.name
        onValueChanged = {
            guard let value = Float($0) else { return }
            item.change(to: value)
        }
        getter = { String(describing: item.getter()) }
        description = item.description
        hasErrorMessage = {
            guard let value = Float($0) else { return "Invalid value" }
            return item.lastErrorMessageIfInvalid(value: value)
        }
    }

    init(item: PreferencesDoubleItem) {
        value = String(describing: item.getter())
        title = item.name
        onValueChanged = {
            guard let value = Double($0) else { return }
            item.change(to: value)
        }
        getter = { String(describing: item.getter()) }
        description = item.description
        hasErrorMessage = {
            guard let value = Double($0) else { return "Invalid value" }
            return item.lastErrorMessageIfInvalid(value: value)
        }
    }
}
