//
//  PreferencesPickerView.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import SwiftUI

struct PreferencesPickerView: View {

    @State var selectedOption: String
    let title: String
    let values: [any PickerValue]
    let onValueChanged: (any PickerValue) -> Void

    var body: some View {
        Picker(selection: $selectedOption) {
            ForEach(values.map(\.description), id: \.self) { option in
                Text(option)
            }
        } label: {
            Text(title)
                .font(.body2Bold)
        }
        .onChange(of: selectedOption) { value in
            guard let currentValue = values.first(where: { $0.description == value }) else { return }
            onValueChanged(currentValue)
        }
    }
}

extension PreferencesPickerView {

    init(item: PreferencesPickerItem) {
        selectedOption = item.getter().description
        title = item.name
        values = item.values
        onValueChanged = item.change
    }
}
