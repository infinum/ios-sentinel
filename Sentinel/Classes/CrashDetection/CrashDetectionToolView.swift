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

    @State private var crashes: [CrashModel.Searchable] = []
    @State private var selectedItem: Int?
    @State private var searchText = ""

    private var searchTerms: [String] {
        searchText.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
    }

    var body: some View {
        let results = crashes.compactMap { $0.result(for: searchTerms) }

        List {
            if crashes.isEmpty {
                Text("No crashes available")
            } else if results.isEmpty {
                Text(verbatim: "No crashes match '\(searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
            } else {
                ForEach(results) { result in
                    NavigationLink(
                        destination: CrashDetectionToolDetailsView(crashModel: result.crash),
                        tag: result.id,
                        selection: $selectedItem,
                        label: { CrashRow(crash: result.crash, matchedFrame: result.matchedFrame) }
                    )
                }
            }
        }
        .searchableIfAvailable(text: $searchText, prompt: "Search crashes")
        .onAppear {
            crashes = (CrashFileManager.recover(ofType: .nsexception) + CrashFileManager.recover(ofType: .signal))
                .enumerated()
                .map { CrashModel.Searchable(id: $0.offset, crash: $0.element) }
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
                .disabled(!searchTerms.isEmpty)
            }
        }
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
