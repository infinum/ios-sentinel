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
        } else if let item = preferenceItem as? PreferencesBoolItem {
            OptionToggleView(item: item)
        } else if let item = preferenceItem as? PreferencesIntItem {
            PreferenceTextView(item: item)
        } else if let item = preferenceItem as? PreferencesPickerItem {
            PreferencesPickerView(item: item)
        }
    }
}
