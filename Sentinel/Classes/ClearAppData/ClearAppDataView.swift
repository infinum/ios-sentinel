//
//  ClearAppDataView.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import SwiftUI

struct ClearAppDataView: View {

    // `SentinelListView` rebuilds every navigation destination on each body evaluation, so an
    // observed object created inline would be replaced while a clear is still running and the
    // result would land on a discarded view model.
    @StateObject var viewModel: ClearAppDataViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("""
            Removes this app's user defaults, caches, temporary files, Documents, \
            Application Support, cookies, web site data and keychain items, leaving it in the \
            state of a fresh install.
            """)
                .font(.body1Regular)
                .multilineTextAlignment(.center)

            Button(action: viewModel.didTapClearAll) {
                Text("Clear all data")
                    .font(.body1Bold)
                    .foregroundColor(.red)
            }
            .disabled(viewModel.isClearing)

            if viewModel.isClearing {
                ProgressView()
            }
        }
        .padding(24)
        .navigationTitle(viewModel.name)
        .alert(item: $viewModel.activeAlert, content: alert(for:))
    }
}

// MARK: - Alerts

private extension ClearAppDataView {

    func alert(for kind: ClearAppDataViewModel.AlertKind) -> Alert {
        switch kind {
        case .confirmation:
            return Alert(
                title: Text("Clear all app data?"),
                message: Text("This can't be undone."),
                primaryButton: .destructive(Text("Clear"), action: viewModel.didConfirmClearAll),
                secondaryButton: .cancel()
            )
        case .result(let report):
            return Alert(
                title: Text(report.title),
                message: Text(report.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
