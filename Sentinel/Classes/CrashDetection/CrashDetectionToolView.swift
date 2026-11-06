//
//  CrashDetectionToolView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

import SwiftUI

struct CrashDetectionToolView: View {

    @State private var crashes: [CrashModel] = []
    @State private var selectedItem: String?

    var body: some View {
        #if os(macOS)
        // This view is already the detail column of the tool list's split view, and a nested
        // NavigationSplitView lays its detail column out past the window edge.
        HSplitView {
            ContentView(crashes: $crashes, selectedItem: $selectedItem)
                .frame(minWidth: 300)

            Group {
                if let crash = crashes.first(where: { $0.selectionID == selectedItem }) {
                    CrashDetectionToolDetailsView(crashModel: crash)
                } else {
                    Color.clear
                }
            }
            .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
        }
        #else
        ContentView(crashes: $crashes, selectedItem: $selectedItem)
        #endif
    }
}

private struct ContentView: View {

    @Binding var crashes: [CrashModel]
    @Binding var selectedItem: String?

    var body: some View {
        List(selection: listSelection) {
            if crashes.isEmpty {
                Text("No crashes available")
            } else {
                ForEach(crashes, id: \.details.date) { model in
                    #if os(macOS)
                    // The split view's detail column shows the selected crash.
                    Text(model.details.name)
                        .tag(model.selectionID)
                    #else
                    NavigationLink(
                        destination: CrashDetectionToolDetailsView(crashModel: model)
                            .navigationBarMaterialBackground(),
                        tag: model.selectionID,
                        selection: $selectedItem,
                        label: { Text(model.details.name) }
                    )
                    #endif
                }
            }
        }
        .pushedListTopMargin(isPushed: true)
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
                        selectedItem = nil
                    },
                    label: {
                        Image(systemName: "trash")
                    }
                )
                .accessibilityIdentifier(AccessibilityIdentifier.crashesDeleteAllButton)
            }
        }
    }
}

private extension ContentView {

    /// On iOS rows push through `NavigationLink`, so the list itself doesn't track a selection.
    var listSelection: Binding<String?>? {
        #if os(macOS)
        $selectedItem
        #else
        nil
        #endif
    }
}

private extension CrashModel {

    /// Crashes are listed by their date, so it doubles as the selection value.
    var selectionID: String {
        details.date.description
    }
}
