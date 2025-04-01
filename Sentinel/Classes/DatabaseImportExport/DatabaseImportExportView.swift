//
//  DatabaseImportExportView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 12.03.2025..
//

import SwiftUI
import UniformTypeIdentifiers

struct DatabaseImportExportView: View {

    @ObservedObject var viewModel: DatabaseImportExportViewModel

    @State private var showPicker = false
    @State private var showShare = false

    var body: some View {
        VStack(spacing: 30) {
            Button(action: { showPicker = true }) {
                Text("Import Database")
            }

            Button(action: { viewModel.exportDatabase() }) {
                Text("Export Database")
            }
            .fileImporter(isPresented: $showPicker, allowedContentTypes: viewModel.allowedTypes) {
                guard case .success(let url) = $0 else { return }
                viewModel.importDatabase(url: url)
            }
            .onChange(of: viewModel.selectedURL) {
                guard $0 != nil else { return }
                showShare = true
            }
            #if os(macOS)
            .background(
                SharingsPicker(
                    isPresented: $showShare,
                    sharingItems: [viewModel.selectedURL as Any],
                    didFinish: { viewModel.selectedURL = nil }
                )
            )
            #else
            .sheet(isPresented: $showShare) {
                ActivityViewController(
                    activityItems: [viewModel.selectedURL as Any],
                    applicationActivities: nil,
                    didFinish: { viewModel.selectedURL = nil }
                )
            }
            #endif
        }
    }
}
