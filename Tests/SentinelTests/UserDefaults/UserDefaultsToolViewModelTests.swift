//
//  UserDefaultsToolViewModelTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("User defaults list")
struct UserDefaultsToolViewModelTests {

    private let isolatedDefaults = IsolatedUserDefaults()

    @Test("Sections stay empty until they are updated")
    func emptyBeforeUpdate() {
        let viewModel = UserDefaultsToolViewModel(name: "Defaults", userDefaults: isolatedDefaults.defaults)

        #expect(viewModel.name == "Defaults")
        #expect(viewModel.sections.isEmpty)
    }

    @Test("Updating lists every key, sorted, in one section")
    func listsSortedKeys() throws {
        // The suite also inherits global-domain keys, so only check the ones written here.
        isolatedDefaults.defaults.set("value", forKey: "sentinel.tests.b")
        isolatedDefaults.defaults.set(42, forKey: "sentinel.tests.a")
        let viewModel = UserDefaultsToolViewModel(name: "Defaults", userDefaults: isolatedDefaults.defaults)

        viewModel.updateSections()

        let section = try #require(viewModel.sections.first)
        let ids = section.items.map(\.id)
        #expect(viewModel.sections.count == 1)
        #expect(ids == ids.sorted())
        #expect(ids.filter { $0.hasPrefix("sentinel.tests.") } == ["sentinel.tests.a", "sentinel.tests.b"])
    }

    @Test("Rows show the value described as a string")
    func rowValues() throws {
        isolatedDefaults.defaults.set(42, forKey: "sentinel.tests.number")
        let viewModel = UserDefaultsToolViewModel(name: "Defaults", userDefaults: isolatedDefaults.defaults)

        viewModel.updateSections()

        let row = try #require(viewModel.sections.first?.items.first { $0.id == "sentinel.tests.number" })
        guard case .navigation(let item) = row else {
            Issue.record("Expected a navigation row")
            return
        }
        #expect(item.value == "42")
    }

    @Test("Removed keys disappear on the next update")
    func removedKeysDisappear() {
        isolatedDefaults.defaults.set("value", forKey: "sentinel.tests.removed")
        let viewModel = UserDefaultsToolViewModel(name: "Defaults", userDefaults: isolatedDefaults.defaults)
        viewModel.updateSections()

        isolatedDefaults.defaults.removeObject(forKey: "sentinel.tests.removed")
        viewModel.updateSections()

        #expect(viewModel.sections.first?.items.contains { $0.id == "sentinel.tests.removed" } == false)
    }
}
