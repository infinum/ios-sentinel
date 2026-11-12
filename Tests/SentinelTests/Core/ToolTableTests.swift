//
//  ToolTableTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import SwiftUI
import Testing
@testable import Sentinel

@Suite("Tool table")
struct ToolTableTests {

    @Test("init(name:items:) wraps the items in a single untitled section")
    func itemsInitWrapsInSingleSection() {
        let table = ToolTable(
            name: "Table",
            items: [
                .customInfo(CustomInfoTool.Item(title: "A", value: "1")),
                .customInfo(CustomInfoTool.Item(title: "B", value: "2"))
            ]
        )

        #expect(table.name == "Table")
        #expect(table.sections.count == 1)
        #expect(table.sections.first?.title == nil)
        #expect(table.sections.first?.items.map(\.id) == ["A", "B"])
    }

    @Test("A titled section uses its title as id")
    func titledSectionId() {
        let section = ToolTableSection(title: "Title", items: [])

        #expect(section.id == "Title")
    }

    @Test("Untitled sections get unique ids")
    func untitledSectionIdsAreUnique() {
        let first = ToolTableSection(items: [])
        let second = ToolTableSection(items: [])

        #expect(first.id != second.id)
    }

    @Test("Every ToolTableItem case uses the wrapped item's title as id")
    func itemIds() {
        let defaults = IsolatedUserDefaults()
        let items: [ToolTableItem] = [
            .navigation(makeNavigationItem(title: "Navigation")),
            .toggle(PreferenceToggleItem(title: "Toggle", userDefaults: defaults.defaults, userDefaultsKey: "key")),
            .customInfo(CustomInfoTool.Item(title: "Info", value: "value")),
            .performance(PerformanceInfoItem(title: "Performance", valueDidChange: { "" })),
            .custom(MockCustomItem(title: "Custom"))
        ]

        #expect(items.map(\.id) == ["Navigation", "Toggle", "Info", "Performance", "Custom"])
    }

    @Test("NavigationToolItem equality only compares titles")
    func navigationItemEquality() {
        #expect(makeNavigationItem(title: "A", value: "1") == makeNavigationItem(title: "A", value: "2"))
        #expect(makeNavigationItem(title: "A") != makeNavigationItem(title: "B"))
    }

    @Test("CustomInfoTool.Item equality only compares titles")
    func customInfoItemEquality() {
        #expect(CustomInfoTool.Item(title: "A", value: "1") == CustomInfoTool.Item(title: "A", value: "2"))
        #expect(CustomInfoTool.Item(title: "A", value: "1") != CustomInfoTool.Item(title: "B", value: "1"))
    }

    @Test("CustomInfoTool maps every section into a table named Information")
    func customInfoToolCreatesTable() {
        let tool = CustomInfoTool(
            name: "Custom",
            info: [
                CustomInfoTool.Section(title: "First", items: [CustomInfoTool.Item(title: "A", value: "1")]),
                CustomInfoTool.Section(
                    title: "Second",
                    items: [
                        CustomInfoTool.Item(title: "B", value: "2"),
                        CustomInfoTool.Item(title: "C", value: "3")
                    ]
                )
            ]
        )

        let table = tool.createToolTable(with: tool.info)

        #expect(tool.name == "Custom")
        #expect(table.name == "Information")
        #expect(table.sections.map(\.title) == ["First", "Second"])
        #expect(table.sections.map { $0.items.map(\.id) } == [["A"], ["B", "C"]])
    }
}

private extension ToolTableTests {

    func makeNavigationItem(title: String, value: String? = nil) -> NavigationToolItem {
        #if os(iOS)
        NavigationToolItem(
            title: title,
            itemValue: value,
            didSelect: { Text(title) }
        )
        #else
        NavigationToolItem(
            title: title,
            itemValue: value,
            didSelect: { _ in Text(title) }
        )
        #endif
    }
}
