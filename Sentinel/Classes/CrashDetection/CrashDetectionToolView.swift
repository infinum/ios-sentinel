//
//  CrashDetectionToolView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

import SwiftUI

struct CrashDetectionToolView: View {

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
                        destination: CrashDetectionToolDetailsView(crashModel: model),
                        tag: String(model.details.date.timeIntervalSinceReferenceDate),
                        selection: $selectedItem,
                        label: { CrashRow(crash: model) }
                    )
                }
            }
        }
        .onAppear {
            crashes = CrashFileManager.recover(ofType: .nsexception) + CrashFileManager.recover(ofType: .signal)
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
                        CrashFileManager.deleteAll()
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

private struct CrashRow: View {

    let crash: CrashModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(crash.details.name)
                .font(.body1Bold)
            Text(crash.details.formattedDate)
                .font(.caption1Regular)
                .foregroundColor(.secondary)
        }
    }
}
