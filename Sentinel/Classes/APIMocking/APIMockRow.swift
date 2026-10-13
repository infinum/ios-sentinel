//
//  APIMockRow.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI

struct APIMockRow: View {

    let mock: APIMock
    let warning: String?
    @Binding var isOn: Bool
    let isEditable: Bool
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
                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        Text(mock.responseSummary)
                            .font(.caption1Regular.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    if !mock.description.isEmpty {
                        Text(mock.description)
                            .font(.caption1Regular)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    if let warning {
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
                .disabled(!isEditable)
                .accessibilityIdentifier(AccessibilityIdentifier.toggle(mock.name))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Helpers

private extension APIMockRow {

    /// Green for a successful response, red for an error status or a network error, grey otherwise.
    var statusColor: Color {
        switch mock.response {
        case .http(let statusCode, _, _):
            switch statusCode {
            case 200..<300: return .green
            case 400..<600: return .red
            default: return .gray
            }
        case .networkError:
            return .red
        }
    }
}
