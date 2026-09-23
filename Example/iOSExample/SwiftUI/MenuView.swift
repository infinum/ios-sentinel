//
//  MenuView.swift
//  Example-iOS
//
//  Created by Nikola Simunko on 22.09.2025..
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

/// Demonstrates `ClearAppDataTool`: save the current state, clear the app data from Sentinel, then
/// relaunch — both values should read as empty again.
struct MenuView: View {

    @State private var userDefaultsValue: String?
    @State private var keychainValue: String?

    var body: some View {
        List {
            Section(header: Text("Stored state")) {
                row(title: "User defaults", description: userDefaultsValue)
                row(title: "Keychain", description: keychainValue)
            }

            Section {
                Button("Save current state") {
                    StoredDataProvider.save()
                    reload()
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Menu")
        .onAppear(perform: reload)
    }
}

// MARK: - Helpers

private extension MenuView {

    func row(title: String, description: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(description ?? "No data stored")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    func reload() {
        userDefaultsValue = StoredDataProvider.userDefaultsValue
        keychainValue = StoredDataProvider.keychainValue
    }
}
