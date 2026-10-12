//
//  Mocks.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import SwiftUI
@testable import Sentinel

// MARK: - MockTrigger

final class MockTrigger: Trigger {

    private(set) var events: (() -> ())?

    func subscribe(on events: @escaping () -> ()) {
        self.events = events
    }

    func fire() {
        events?()
    }
}

// MARK: - MockSourceScreenProvider

final class MockSourceScreenProvider: SourceScreenProvider {

    var isShownResult = false
    private(set) var showToolsCount = 0
    private(set) var isShownCount = 0
    private(set) var dismissCount = 0

    func showTools(for view: some View) {
        showToolsCount += 1
    }

    func isShown() -> Bool {
        isShownCount += 1
        return isShownResult
    }

    func dismiss() {
        dismissCount += 1
    }
}

// MARK: - MockTool

struct MockTool: Tool {

    let name: String

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View {
        Text(name)
    }
    #else
    var content: any View {
        Text(name)
    }
    #endif
}

// MARK: - MockCustomItem

struct MockCustomItem: CustomToolTableItem {

    let title: String

    var content: any View {
        Text(title)
    }
}
