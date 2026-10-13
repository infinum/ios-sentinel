//
//  APIMockRow.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI

struct APIMockRow: View {

    let mock: APIMock
    @Binding var isOn: Bool
    let didSelect: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // A plain button, so only the text opens the mock and the switch keeps its own taps.
            Button(action: didSelect) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mock.name)
                        .font(.body1Bold)
                    Text(mock.requestSummary)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .truncationMode(.middle)
                    Text(mock.responseSummary)
                        .font(.caption1Regular)
                        .foregroundColor(.secondary)
                    if !mock.description.isEmpty {
                        Text(mock.description)
                            .font(.caption1Regular)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    if let warning = mock.warning {
                        Text(warning)
                            .font(.caption1Regular)
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityIdentifier.row(mock.name))

            Toggle(mock.name, isOn: $isOn)
                .labelsHidden()
                #if os(macOS)
                .toggleStyle(.switch)
                #endif
                .accessibilityIdentifier(AccessibilityIdentifier.toggle(mock.name))
        }
        .padding(.vertical, 4)
    }
}
