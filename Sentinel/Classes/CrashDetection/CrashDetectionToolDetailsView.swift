//
//  CrashDetectionToolDetailsView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

import SwiftUI

struct CrashDetectionToolDetailsView: View {

    @State private var showShare = false

    let crashModel: CrashModel

    var body: some View {
        List {
            Section {
                Text("Details")
                    .font(.title1Bold)

                ForEach(detailItems, id: \.0) {
                    CrashToolDetailsRow(title: $0.0, value: $0.1)
                }
            }

            Section {
                Text("Stack trace")
                    .font(.title1Bold)

                ForEach(crashModel.traces, id: \.title) {
                    StackTraceView(title: $0.title, description: $0.detail)
                }
            }
        }
        .toolbar {
            #if os(macOS)
            let placement = ToolbarItemPlacement.navigation
            #else
            let placement = ToolbarItemPlacement.topBarTrailing
            #endif

            ToolbarItemGroup(placement: placement) {
                Button(
                    action: {
                        showShare = true
                    },
                    label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                )
            }
        }
        .share(
            showShare: $showShare,
            items: [shareText as Any],
            didFinish: { showShare = false }
        )
    }
}

private struct CrashToolDetailsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.body1Bold)
            Text(value)
                .font(.body1Regular)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

private struct StackTraceView: View {
    let title: String
    let description: String?

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.body1Bold)
            if let description {
                Text(description)
                    .font(.caption1Regular)
            }
        }
        .onTapGesture { }
        .onLongPressGesture {
            #if os(macOS)
            NSPasteboard.general.setString(title + String.newLine + (description ?? .empty), forType: .string)
            #else
            UIPasteboard.general.string = title + String.newLine + (description ?? .empty)
            #endif
        }
    }
}

private extension CrashDetectionToolDetailsView {

    var detailItems: [(String, String)] {
        [
            ("Error:", crashModel.details.name),
            ("Date:", crashModel.details.date.description),
            ("Other:", crashModel.details.deviceInfo.description)
        ]
    }

    @StringBuilder
    var shareText: String {
        detailItems.map { title, value in
            "\(title): \(value)"
        }.joined(separator: .newLine)
        String.newLine

        "Stack Trace:"
        String.newLine

        crashModel.traces.map { trace in
            trace.title + String.newLine + trace.detail
        }.joined(separator: .newLine + .newLine)
    }
}
