//
//  PreferencesToolTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing
@testable import Sentinel

@Suite("Preferences tool")
struct PreferencesToolTests {

    private let isolatedDefaults = IsolatedUserDefaults()

    @Test("Each preferences section becomes a section of toggle rows")
    func sectionsMapToToggleRows() {
        let tool = PreferencesTool(
            sections: [
                PreferencesTool.Section(
                    title: "Flags",
                    items: [
                        PreferenceToggleItem(
                            title: "A",
                            userDefaults: isolatedDefaults.defaults,
                            userDefaultsKey: "a"
                        ),
                        PreferencesTextItem(
                            title: "B",
                            userDefaults: isolatedDefaults.defaults,
                            userDefaultsKey: "b"
                        )
                    ]
                ),
                PreferencesTool.Section(title: nil, items: [])
            ]
        )

        let sections = tool.toolTable.sections

        #expect(tool.name == "Preferences")
        #expect(tool.toolTable.name == "Preferences")
        #expect(sections.map(\.title) == ["Flags", nil])
        #expect(sections.first?.items.map(\.id) == ["A", "B"])
        for item in sections.first?.items ?? [] {
            guard case .toggle = item else {
                Issue.record("Expected a toggle row, got \(item)")
                continue
            }
        }
    }

    @Test("A titled section uses its title as id, an untitled one gets a unique id")
    func sectionIds() {
        #expect(PreferencesTool.Section(title: "Title", items: []).id == "Title")
        #expect(PreferencesTool.Section(title: nil, items: []).id != PreferencesTool.Section(title: nil, items: []).id)
    }
}
