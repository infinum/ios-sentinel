//
//  CrashToolDetailsView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

import SwiftUI

struct CrashToolDetailsView: View {

    let crashModel: CrashModel

    var body: some View {
        List {
            Section {
                Text("Details")
                    .font(.headline)

                ForEach(detailItems, id: \.0) {
                    CrashToolDetailsRow(title: $0.0, value: $0.1)
                }
            }

            Section {
                Text("Stack trace")
                    .font(.headline)

                ForEach(crashModel.traces, id: \.title) {
                    StackTraceView(title: $0.title, description: $0.detail)
                }
            }
        }
    }
}

private struct CrashToolDetailsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
            Text(value)
                .font(.system(size: 14))
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
                .font(.system(size: 14, weight: .bold))
            if let description {
                Text(description)
                    .font(.system(size: 11))
            }
        }
        .onTapGesture { }
        .onLongPressGesture {
            #if os(macOS)
            NSPasteboard.general.setString(title, forType: .string)
            #else
            UIPasteboard.general.string = title
            #endif
        }
    }
}

private extension CrashToolDetailsView {

    var detailItems: [(String, String)] {
        [
            ("Error:", crashModel.details.name),
            ("Date:", crashModel.details.date.description),
            ("Other:", crashModel.details.deviceInfo.description)
        ]
    }
}
