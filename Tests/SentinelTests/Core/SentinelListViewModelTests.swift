//
//  SentinelListViewModelTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing
@testable import Sentinel

@Suite("Sentinel list search")
struct SentinelListViewModelTests {

    private let viewModel = SentinelListViewModel(
        sections: [
            ToolTableSection(
                title: "Device",
                items: [
                    .customInfo(CustomInfoTool.Item(title: "Model", value: "iPhone")),
                    .customInfo(CustomInfoTool.Item(title: "System version", value: "26"))
                ]
            ),
            ToolTableSection(
                title: "App",
                items: [
                    .customInfo(CustomInfoTool.Item(title: "App version", value: "1.0")),
                    .customInfo(CustomInfoTool.Item(title: "Bundle id", value: "com.infinum"))
                ]
            )
        ]
    )

    @Test("Without search text all sections are shown")
    func initialSections() {
        #expect(viewModel.sections.map(\.title) == ["Device", "App"])
    }

    @Test(
        "Search matches item titles case-insensitively by substring",
        arguments: [
            ("version", ["System version", "App version"]),
            ("VERSION", ["System version", "App version"]),
            ("mod", ["Model"]),
            ("e i", ["Bundle id"])
        ]
    )
    func searchFilters(query: String, expectedIds: [String]) {
        viewModel.searchText = query

        #expect(viewModel.sections.count == 1)
        #expect(viewModel.sections.first?.title == nil)
        #expect(viewModel.sections.first?.items.map(\.id) == expectedIds)
    }

    @Test("Search only matches titles, not values")
    func searchIgnoresValues() {
        viewModel.searchText = "iPhone"

        #expect(viewModel.sections.first?.items.isEmpty == true)
    }

    @Test("A search without matches leaves one empty section")
    func noMatches() {
        viewModel.searchText = "nothing matches this"

        #expect(viewModel.sections.count == 1)
        #expect(viewModel.sections.first?.items.isEmpty == true)
    }

    @Test("Whitespace is not trimmed from the query")
    func whitespaceIsNotTrimmed() {
        viewModel.searchText = " Model"

        #expect(viewModel.sections.first?.items.isEmpty == true)
    }

    @Test("Clearing the search restores the original sections")
    func clearingRestoresSections() {
        viewModel.searchText = "version"
        viewModel.searchText = ""

        #expect(viewModel.sections.map(\.title) == ["Device", "App"])
        #expect(viewModel.sections.map(\.items.count) == [2, 2])
    }
}
