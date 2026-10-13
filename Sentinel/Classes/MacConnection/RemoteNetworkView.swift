//
//  RemoteNetworkView.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

#if os(macOS)

import AppKit
import SwiftUI

/// The app's requests in Sentinel for Mac, newest first, with the selected one in detail.
struct RemoteNetworkView: View {

    @ObservedObject var device: RemoteDevice
    @State private var selectedID: RemoteNetworkEntry.ID?
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Filter by URL, method or status", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Button("Clear") {
                    selectedID = nil
                    device.clearNetworkEntries()
                }
                .disabled(device.networkEntries.isEmpty)
            }
            .padding(8)

            if device.droppedNetworkEntryCount > 0 {
                Text("\(device.droppedNetworkEntryCount) requests were left out because the connection fell behind.")
                    .font(.caption1Regular)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15))
            }

            HSplitView {
                table
                    .frame(minWidth: 420)
                detail
                    .frame(minWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Table

private extension RemoteNetworkView {

    var table: some View {
        Table(filteredEntries, selection: $selectedID) {
            TableColumn("Status") { entry in
                Text(entry.statusText)
                    .foregroundColor(entry.statusColor)
            }
            .width(min: 44, ideal: 56, max: 80)

            TableColumn("Method") { entry in
                Text(entry.method)
                    .font(.system(.body, design: .monospaced))
            }
            .width(min: 50, ideal: 64, max: 90)

            TableColumn("URL") { entry in
                HStack(spacing: 6) {
                    if entry.isMocked {
                        Text("MOCK")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(Color.orange.opacity(0.3)))
                    }
                    Text(entry.url)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            TableColumn("Time") { entry in
                Text(entry.durationText)
                    .foregroundColor(.secondary)
            }
            .width(min: 50, ideal: 64, max: 90)
        }
    }

    var filteredEntries: [RemoteNetworkEntry] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        let entries = device.networkEntries.reversed()
        guard !query.isEmpty else { return Array(entries) }
        return entries.filter { entry in
            [entry.url, entry.method, entry.statusText].contains { $0.lowercased().contains(query) }
        }
    }

    @ViewBuilder
    var detail: some View {
        if let entry = device.networkEntries.first(where: { $0.id == selectedID }) {
            RemoteNetworkEntryView(entry: entry)
        } else {
            Text(device.networkEntries.isEmpty ? "Requests the app makes show up here." : "Select a request.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Entry

private struct RemoteNetworkEntryView: View {

    private enum Part: Hashable {
        case request
        case response
    }

    let entry: RemoteNetworkEntry
    @State private var part = Part.response

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(entry.method) \(entry.url)")
                .font(.system(.body, design: .monospaced))
                .lineLimit(4)
                .textSelection(.enabled)
            HStack(spacing: 12) {
                Text(entry.statusText)
                    .foregroundColor(entry.statusColor)
                if !entry.durationText.isEmpty {
                    Text(entry.durationText)
                }
                if entry.isMocked {
                    Text("Answered by an API mock")
                }
            }
            .font(.caption1Regular)
            .foregroundColor(.secondary)
            if let error = entry.errorDescription {
                Text(error)
                    .font(.caption1Regular)
                    .foregroundColor(.red)
            }
            Picker("Part", selection: $part) {
                Text("Response").tag(Part.response)
                Text("Request").tag(Part.request)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            ReadOnlyTextView(text: text(for: part))
        }
        .padding(12)
    }

    private func text(for part: Part) -> String {
        switch part {
        case .request:
            return Self.text(headers: entry.requestHeaders, body: entry.requestBody)
        case .response:
            guard entry.isCompleted else { return "Waiting for the response…" }
            return Self.text(headers: entry.responseHeaders, body: entry.responseBody)
        }
    }

    private static func text(headers: [String: String], body: RemoteNetworkEntry.Body?) -> String {
        let headerLines = headers
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
        return [headerLines.isEmpty ? "No headers" : headerLines, body?.displayText ?? "No body"]
            .joined(separator: "\n\n")
    }
}

/// An `NSTextView`, as SwiftUI's `Text` slows to a crawl on a body of a megabyte.
private struct ReadOnlyTextView: NSViewRepresentable {

    let text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        if let textView = scrollView.documentView as? NSTextView {
            textView.isEditable = false
            textView.isSelectable = true
            textView.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            textView.textContainerInset = NSSize(width: 4, height: 6)
        }
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView, textView.string != text else { return }
        textView.string = text
    }
}

// MARK: - Presentation

private extension RemoteNetworkEntry {

    var statusText: String {
        if let statusCode {
            return "\(statusCode)"
        }
        if errorDescription != nil {
            return "Failed"
        }
        return isCompleted ? "–" : "…"
    }

    var statusColor: Color {
        if errorDescription != nil {
            return .red
        }
        return statusCode.map(Color.httpStatus) ?? .secondary
    }

    var durationText: String {
        guard let duration else { return "" }
        return duration < 1 ? "\(Int(duration * 1000)) ms" : String(format: "%.2f s", duration)
    }
}

private extension RemoteNetworkEntry.Body {

    var displayText: String {
        guard let text = readableText else {
            return "\(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)) of binary data"
        }
        guard isTruncated else {
            return JSONFormatter.prettyPrinted(text) ?? text
        }
        let shown = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
        let total = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
        return "\(text)\n\n— Showing the first \(shown) of \(total). —"
    }

    /// The body as UTF-8 text. A cut-off body may end partway through a character, which is dropped.
    var readableText: String? {
        for trailingBytes in 0...3 where data.count >= trailingBytes {
            if let text = String(data: data.dropLast(trailingBytes), encoding: .utf8) {
                return text
            }
            guard isTruncated else { return nil }
        }
        return nil
    }
}

#endif
