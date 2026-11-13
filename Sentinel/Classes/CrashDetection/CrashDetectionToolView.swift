//
//  CrashDetectionToolView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

import SwiftUI

struct CrashDetectionToolView: View {

    @State private var crashes: [CrashModel.Searchable] = []
    @State private var selectedItem: CrashModel.Searchable.ID?

    var body: some View {
        #if os(macOS)
        // This view is already the detail column of the tool list's split view, and a nested
        // NavigationSplitView lays its detail column out past the window edge.
        HSplitView {
            ContentView(crashes: $crashes, selectedItem: $selectedItem)
                .frame(minWidth: 300)

            Group {
                if let crash = crashes.first(where: { $0.id == selectedItem })?.crash {
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

    @Binding var crashes: [CrashModel.Searchable]
    @Binding var selectedItem: CrashModel.Searchable.ID?
    @State private var searchText = ""

    private var searchTerms: [String] {
        searchText.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
    }

    var body: some View {
        let results = crashes.compactMap { $0.result(for: searchTerms) }

        List(selection: listSelection) {
            if crashes.isEmpty {
                Text("No crashes available")
            } else if results.isEmpty {
                Text(verbatim: "No crashes match '\(searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
            } else {
                ForEach(results) { result in
                    #if os(macOS)
                    // The split view's detail column shows the selected crash.
                    CrashRow(crash: result.crash, matchedFrame: result.matchedFrame)
                        .tag(result.id)
                    #else
                    NavigationLink(
                        destination: CrashDetectionToolDetailsView(crashModel: result.crash)
                            .navigationBarMaterialBackground(),
                        tag: result.id,
                        selection: $selectedItem,
                        label: { CrashRow(crash: result.crash, matchedFrame: result.matchedFrame) }
                    )
                    #endif
                }
            }
        }
        .sentinelSearchable(text: $searchText, prompt: "Search crashes")
        .pushedListTopMargin(isPushed: true)
        .onAppear {
            crashes = CrashModel.Searchable.list(from: CrashFileManager.recoverAll())
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
                .disabled(!searchTerms.isEmpty)
                .accessibilityIdentifier(AccessibilityIdentifier.crashesDeleteAllButton)
            }
        }
    }
}

private extension ContentView {

    /// On iOS rows push through `NavigationLink`, so the list itself doesn't track a selection.
    var listSelection: Binding<CrashModel.Searchable.ID?>? {
        #if os(macOS)
        $selectedItem
        #else
        nil
        #endif
    }
}

private struct CrashRow: View {

    let crash: CrashModel
    let matchedFrame: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(crash.details.name)
                .font(.body1Bold)
            Text(crash.details.formattedDate)
                .font(.caption1Regular)
                .foregroundColor(.secondary)
            if let matchedFrame {
                Text(verbatim: "Matched in: \(matchedFrame)")
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}
