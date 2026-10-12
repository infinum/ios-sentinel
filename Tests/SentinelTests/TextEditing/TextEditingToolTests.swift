//
//  TextEditingToolTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Text editing tool")
struct TextEditingToolTests {

    private let isolatedDefaults = IsolatedUserDefaults()
    private let key = "base_url"

    @Test("Saving writes the key and calls the setter")
    func storeWritesAndCallsSetter() {
        var value = "initial"
        let tool = TextEditingTool(
            name: "Base URL",
            setter: { value = $0 },
            getter: { value },
            userDefaults: isolatedDefaults.defaults,
            userDefaultsKey: key
        )

        tool.store(newValue: "https://example.com")

        #expect(value == "https://example.com")
        #expect(isolatedDefaults.defaults.string(forKey: key) == "https://example.com")
    }

    @Test("A stored value is applied when the tool is created")
    func storedValueIsLoaded() {
        isolatedDefaults.defaults.set("https://stored.example.com", forKey: key)
        var value = "initial"

        _ = TextEditingTool(
            name: "Base URL",
            setter: { value = $0 },
            getter: { value },
            userDefaults: isolatedDefaults.defaults,
            userDefaultsKey: key
        )

        #expect(value == "https://stored.example.com")
    }

    @Test("Without a stored value the setter isn't called")
    func noStoredValue() {
        var setterCalls = 0

        _ = TextEditingTool(
            name: "Base URL",
            setter: { _ in setterCalls += 1 },
            getter: { "" },
            userDefaults: isolatedDefaults.defaults,
            userDefaultsKey: key
        )

        #expect(setterCalls == 0)
    }

    @Test("Without a key, saving only calls the setter")
    func noKey() {
        var value = ""
        let tool = TextEditingTool(
            name: "Base URL",
            setter: { value = $0 },
            getter: { value },
            userDefaults: isolatedDefaults.defaults
        )

        tool.store(newValue: "new")

        #expect(value == "new")
        #expect(isolatedDefaults.defaults.string(forKey: key) == nil)
    }

    @Test("The view model passes the saved value on")
    func viewModelSaves() {
        var saved: String?
        let viewModel = TextEditingToolViewModel(
            value: "value",
            title: "Title",
            didPressSave: { saved = $0 }
        )

        viewModel.didPressSave(viewModel.value)

        #expect(viewModel.title == "Title")
        #expect(saved == "value")
    }
}
