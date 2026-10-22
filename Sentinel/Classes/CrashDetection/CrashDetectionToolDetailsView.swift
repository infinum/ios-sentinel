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

                ForEach(detailItems, id: \.title) {
                    CrashToolDetailsRow(title: $0.title, value: $0.value)
                }
            }

            Section {
                Text("Stack trace")
                    .font(.title1Bold)

                ForEach(Array(crashModel.traces.enumerated()), id: \.offset) {
                    StackTraceView(index: $0.offset, trace: $0.element)
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
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption1Regular)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body1Regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
    }
}

private struct StackTraceView: View {
    let index: Int
    let trace: CrashModel.StackTrace

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(header)
                .font(.caption1Regular)
                .foregroundColor(.secondary)
            Text(trace.symbol)
                .font(.body1Regular.monospaced())
            if !detail.isEmpty {
                Text(detail)
                    .font(.caption1Regular)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
        .contextMenu {
            Button("Copy") {
                #if os(macOS)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(copyText, forType: .string)
                #else
                UIPasteboard.general.string = copyText
                #endif
            }
        }
    }

    /// Frame index and image, e.g. "#0 · Example-iOS"
    private var header: String {
        [("#\(index)"), trace.image].compactMap { $0 }.joined(separator: " · ")
    }

    private var detail: String {
        trace.detail.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var copyText: String {
        trace.title + String.newLine + trace.detail
    }
}

private extension CrashDetectionToolDetailsView {

    var detailItems: [(title: String, value: String)] {
        [
            ("Error", crashModel.details.name),
            ("Date", crashModel.details.formattedDateWithTimeZone)
        ] + crashModel.details.deviceInfo.items
    }

    @StringBuilder
    var shareText: String {
        "Error: \(crashModel.details.name)"
        String.newLine
        "Date: \(crashModel.details.formattedDateWithTimeZone)"
        String.newLine
        crashModel.details.deviceInfo.description

        "Stack Trace:"
        String.newLine

        crashModel.traces.map { trace in
            trace.title + String.newLine + trace.detail
        }.joined(separator: .newLine + .newLine)
    }
}
