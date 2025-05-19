//
//  PreferencesView.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import SwiftUI

struct PreferencesView: View {

    let item: any PreferenceItem

    var body: some View {
        if let textItem = item as? PreferencesTextItem {
            PreferenceTextView(item: textItem)
        } else if let toggleItem = item as? PreferenceToggleItem {
            PreferenceToggleView(item: toggleItem)
        } else if let intItem = item as? PreferencesIntItem {
            PreferenceTextView(item: intItem)
        } else if let pickerItem = item as? PreferencesPickerItem {
            PreferencesPickerView(item: pickerItem)
        }
    }
}

struct DescriptionView: View {

    let description: String?
    let errorMessage: String?
    
    var body: some View {
        if let errorMessage {
            Text(errorMessage)
                .font(.caption1Regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.red)
        } else if let description {
            Text(description)
                .font(.caption1Regular)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
