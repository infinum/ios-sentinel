//
//  BuiltInPreferencesTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.11.2026..
//

import Testing
@testable import Sentinel

@Suite("Built-in preferences")
struct BuiltInPreferencesTests {

    private let isolatedDefaults = IsolatedUserDefaults()

    @Test("Without app preferences, the Preferences tab only has the built-in sections")
    func noAppPreferences() throws {
        let sections = try preferencesSections(for: [])

        #if os(iOS)
        #expect(sections.map(\.title) == ["Sentinel"])
        #expect(sections.first?.items.map(\.id) == ["Show touches"])
        #else
        #expect(sections.isEmpty)
        #endif
    }

    @Test("The built-in section comes before the app's own sections")
    func builtInSectionComesFirst() throws {
        let sections = try preferencesSections(for: [
            PreferencesTool.Section(title: "Flags", items: [toggle("A")]),
            PreferencesTool.Section(title: "More flags", items: [toggle("B")])
        ])

        #if os(iOS)
        #expect(sections.map(\.title) == ["Sentinel", "Flags", "More flags"])
        #else
        #expect(sections.map(\.title) == ["Flags", "More flags"])
        #endif
    }

    @Test("An app section titled Sentinel doesn't share the built-in section's identity")
    func appSectionTitledSentinel() throws {
        let sections = try preferencesSections(for: [
            PreferencesTool.Section(title: "Sentinel", items: [toggle("A")])
        ])

        #expect(Set(sections.map(\.id)).count == sections.count)
        #expect(sections.last?.id == "Sentinel")
    }

    @Test("The Preferences tool keeps each section's id")
    func preferencesToolKeepsSectionIds() {
        let section = PreferencesTool.Section(
            id: "custom.id",
            title: "Title",
            items: []
        )

        #expect(PreferencesTool(sections: [section]).toolTable.sections.map(\.id) == ["custom.id"])
    }
}

private extension BuiltInPreferencesTests {

    func preferencesSections(for preferences: [PreferencesTool.Section]) throws -> [ToolTableSection] {
        let tabItems = Sentinel.createTabItems(with: [], preferences: preferences)
        return try #require(tabItems.first { $0.tabViewTab == .preferences }).sections
    }

    func toggle(_ title: String) -> PreferenceToggleItem {
        PreferenceToggleItem(
            title: title,
            userDefaults: isolatedDefaults.defaults,
            userDefaultsKey: title
        )
    }
}
