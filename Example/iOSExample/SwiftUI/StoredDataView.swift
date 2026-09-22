//
//  StoredDataView.swift
//  Example-iOS
//
//  Created by Nikola Simunko on 22.09.2025..
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

/// Demonstrates `ClearAppDataTool`: save a timestamp, clear the app data from Sentinel, then
/// relaunch — both values should read as empty again.
struct StoredDataView: View {

    @State private var userDefaultsValue: String?
    @State private var keychainValue: String?

    var body: some View {
        VStack(spacing: 12) {
            row(title: "User defaults", value: userDefaultsValue)
            row(title: "Keychain", value: keychainValue)

            Button("Save current date") {
                StoredDataProvider.save()
                reload()
            }
            .padding(.top, 8)
        }
        .onAppear(perform: reload)
    }
}

// MARK: - Helpers

private extension StoredDataView {

    func row(title: String, value: String?) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value ?? "No data stored")
                .font(.body)
        }
    }

    func reload() {
        userDefaultsValue = StoredDataProvider.userDefaultsValue
        keychainValue = StoredDataProvider.keychainValue
    }
}
