//
//  DatabaseView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 12.03.2025..
//

import SwiftUI
import UniformTypeIdentifiers

struct DatabaseView: View {

    @ObservedObject var viewModel: DatabaseViewModel

    @State private var showPicker = false
    @State private var showShare = false

    var body: some View {
        VStack(spacing: 32) {
            Button(action: { showPicker = true }) {
                Text("Import database")
            }

            Button(action: { viewModel.exportDatabase() }) {
                Text("Export database")
            }
            .fileImporter(isPresented: $showPicker, allowedContentTypes: viewModel.allowedTypes) {
                guard case .success(let url) = $0 else { return }
                viewModel.importDatabase(url: url)
            }
            .onChange(of: viewModel.selectedURL) {
                guard $0 != nil else { return }
                showShare = true
            }
            .share(
                showShare: $showShare,
                items: [viewModel.selectedURL as Any],
                didFinish: { viewModel.selectedURL = nil }
            )
        }
    }
}
