//
//  CrashToolView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

import SwiftUI

struct CrashToolView: View {

    @State private var crashes: [CrashModel] = []

    var body: some View {
        List {
            if crashes.isEmpty {
                Text("No crashes available")
            } else {
                ForEach(crashes, id: \.details.date) { model in
                    NavigationLink(
                        destination: { CrashToolDetailsView(crashModel: model) },
                        label: {
                            Text(model.details.name)
                        }
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
