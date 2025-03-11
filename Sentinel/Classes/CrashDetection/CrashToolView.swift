//
//  CrashToolView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

import SwiftUI

struct CrashToolView: View {

    var body: some View {
        #if os(macOS)
        NavigationView {
            ContentView()
                .frame(minWidth: 300)
        }
        #else
        ContentView()
        #endif
    }
}

private struct ContentView: View {

    @State private var crashes: [CrashModel] = []
    @State private var selectedItem: String?

    var body: some View {
        List {
            if crashes.isEmpty {
                Text("No crashes available")
            } else {
                ForEach(crashes, id: \.details.date) { model in
                    NavigationLink(
                        destination: CrashToolDetailsView(crashModel: model),
                        tag: model.details.date.description,
                        selection: $selectedItem,
                        label: { Text(model.details.name) }
                    )
                }
            }
        }
        .onAppear {
            crashes = CrashManager.recover(ofType: .nsexception) + CrashManager.recover(ofType: .signal)
        }
        .navigationTitle("Crashes Tool")
        .toolbar {
            #if os(macOS)
            let placement = ToolbarItemPlacement.navigation
            #else
            let placement = ToolbarItemPlacement.topBarTrailing
            #endif

            ToolbarItemGroup(placement: placement) {
                Button(
                    action: {
                        CrashManager.deleteAll()
                        crashes = []
                    },
                    label: {
                        Image(systemName: "trash")
                    }
                )
            }
        }
    }
}
