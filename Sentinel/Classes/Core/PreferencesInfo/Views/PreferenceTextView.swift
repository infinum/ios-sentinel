//
//  PreferenceTextView.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import SwiftUI

struct PreferenceTextView: View {

    @State private var value: String
    let title: String
    let onValueChanged: (String) -> Void
    let getter: () -> String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.body2Bold)
            TextEditor(text: $value)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .border(.gray, width: 1)
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

extension PreferenceTextView {

    init(item: PreferenceTextItem) {
        value = item.getter()
        title = item.name
        onValueChanged = item.change(to:)
        getter = item.getter
    }

    init(item: PreferencesIntItem) {
        value = String(describing: item.getter())
        title = item.name
        onValueChanged = {
            guard let value = Int($0) else { return }
            item.change(to: value)
        }
        getter = { String(describing: item.getter()) }
    }

    init(item: PreferencesFloatItem) {
        value = String(describing: item.getter())
        title = item.name
        onValueChanged = {
            guard let value = Float($0) else { return }
            item.change(to: value)
        }
        getter = { String(describing: item.getter()) }
    }

    init(item: PreferencesDoubleItem) {
        value = String(describing: item.getter())
        title = item.name
        onValueChanged = {
            guard let value = Double($0) else { return }
            item.change(to: value)
        }
        getter = { String(describing: item.getter()) }
    }
}
