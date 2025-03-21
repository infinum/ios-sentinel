//
//  PreferencesView.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import SwiftUI

struct PreferencesView: View {

    let preferenceItem: any PreferenceItem

    var body: some View {
        if let item = preferenceItem as? PreferencesTextItem {
            PreferenceTextView(item: item)
        } else if let item = preferenceItem as? ToggleToolItem {
            OptionToggleView(item: item)
        } else if let item = preferenceItem as? PreferencesIntItem {
            PreferenceTextView(item: item)
        } else if let item = preferenceItem as? PreferencesPickerItem {
            PreferencesPickerView(item: item)
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
