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
    @State private var selectedItem: String?
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
                ForEach(results, id: \.crash.details.date) { result in
                    NavigationLink(
                        destination: CrashDetectionToolDetailsView(crashModel: result.crash),
                        tag: String(result.crash.details.date.timeIntervalSinceReferenceDate),
                        selection: $selectedItem,
                        label: { CrashRow(crash: result.crash, matchedSymbol: result.matchedSymbol) }
                    )
                }
            }
        }
        .searchableIfAvailable(text: $searchText, prompt: "Search crashes")
        .onAppear {
            // The date is the row's ID, so a crash repeating an already seen date is dropped
            var seenDates = Set<Date>()
            crashes = (CrashFileManager.recover(ofType: .nsexception) + CrashFileManager.recover(ofType: .signal))
                .filter { seenDates.insert($0.details.date).inserted }
                .map(CrashModel.Searchable.init)
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
    let matchedSymbol: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(crash.details.name)
                .font(.body1Bold)
            Text(crash.details.formattedDate)
                .font(.caption1Regular)
                .foregroundColor(.secondary)
            if let matchedSymbol {
                Text(verbatim: "Matched in: \(matchedSymbol)")
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}
