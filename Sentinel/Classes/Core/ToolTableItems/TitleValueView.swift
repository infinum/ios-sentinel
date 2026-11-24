//
//  TitleValueView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 27.11.2024..
//

import SwiftUI

struct TitleValueView: View {

    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.body1Bold)

            Text(value)
                .font(.body1Regular)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .contextMenu {
            Button("Copy") { copyToPasteboard() }
        }
    }
}

// MARK: - Private methods

private extension TitleValueView {

    func copyToPasteboard() {
        let text = "\(title): \(value)"
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

// MARK: - Helpers

extension TitleValueView {

    init(item: CustomInfoTool.Item) {
        title = item.title
        value = item.value
    }
}
