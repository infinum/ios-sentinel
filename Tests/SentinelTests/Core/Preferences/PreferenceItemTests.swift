//
//  PreferenceItemTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("Preference items")
struct PreferenceItemTests {

    private let isolatedDefaults = IsolatedUserDefaults()
    private var defaults: UserDefaults { isolatedDefaults.defaults }
    private let key = "preference.key"

    // MARK: - Key-based items

    @Test("Toggle item reads and writes its key")
    func toggleItemPersists() {
        let item = PreferenceToggleItem(
            title: "Toggle",
            userDefaults: defaults,
            userDefaultsKey: key
        )

        #expect(item.getter() == false)
        item.change(to: true)
        #expect(defaults.bool(forKey: key))
        #expect(item.getter())
    }

    @Test("Int item reads and writes its key")
    func intItemPersists() {
        let item = PreferencesIntItem(
            title: "Int",
            userDefaults: defaults,
            userDefaultsKey: key
        )

        #expect(item.getter() == 0)
        item.change(to: 42)
        #expect(defaults.integer(forKey: key) == 42)
        #expect(item.getter() == 42)
    }

    @Test("Float item reads and writes its key")
    func floatItemPersists() {
        let item = PreferencesFloatItem(
            title: "Float",
            userDefaults: defaults,
            userDefaultsKey: key
        )

        #expect(item.getter() == 0)
        item.change(to: 1.5)
        #expect(defaults.float(forKey: key) == 1.5)
        #expect(item.getter() == 1.5)
    }

    @Test("Double item reads and writes its key")
    func doubleItemPersists() {
        let item = PreferencesDoubleItem(
            title: "Double",
            description: nil,
            userDefaults: defaults,
            userDefaultsKey: key
        )

        #expect(item.getter() == 0)
        item.change(to: 2.25)
        #expect(defaults.double(forKey: key) == 2.25)
        #expect(item.getter() == 2.25)
    }

    @Test("Text item reads and writes its key, and reads no-value when unset")
    func textItemPersists() {
        let item = PreferencesTextItem(
            title: "Text",
            userDefaults: defaults,
            userDefaultsKey: key
        )

        #expect(item.getter() == "no-value")
        item.change(to: "hello")
        #expect(defaults.string(forKey: key) == "hello")
        #expect(item.getter() == "hello")
    }

    @Test("Items are identified by their name")
    func itemId() {
        let item = PreferencesTextItem(
            title: "Text",
            userDefaults: defaults,
            userDefaultsKey: key
        )

        #expect(item.id == "Text")
        #expect(item.userDefaultsKey == key)
    }

    // MARK: - Closure-based items

    @Test("Closure-based items call the setter and don't touch user defaults")
    func closureItemsUseClosures() {
        var stored = 0
        let item = PreferencesIntItem(
            title: "Int",
            setter: { stored = $0 },
            getter: { stored }
        )

        item.change(to: 7)

        #expect(stored == 7)
        #expect(item.getter() == 7)
        #expect(item.userDefaultsKey == nil)
    }

    // MARK: - store / loadStoredValue

    @Test("store writes the key and then calls the setter")
    func storeWritesAndCallsSetter() {
        let item = TestPreferenceItem(defaults: defaults, key: key)

        item.store(newValue: "stored")

        #expect(defaults.string(forKey: key) == "stored")
        #expect(item.recorder.values == ["stored"])
    }

    @Test("loadStoredValue calls the setter with the stored value")
    func loadStoredValueCallsSetter() {
        defaults.set("persisted", forKey: key)
        let item = TestPreferenceItem(defaults: defaults, key: key)

        item.loadStoredValue()

        #expect(item.recorder.values == ["persisted"])
    }

    @Test("loadStoredValue skips values of the wrong type and missing values")
    func loadStoredValueSkipsMismatches() {
        let item = TestPreferenceItem(defaults: defaults, key: key)

        item.loadStoredValue()
        defaults.set(Date(), forKey: key)
        item.loadStoredValue()

        #expect(item.recorder.values.isEmpty)
    }

    // MARK: - lastErrorMessageIfInvalid

    @Test("The message of the last failing validator wins")
    func lastFailingValidatorWins() {
        let item = PreferencesIntItem(
            title: "Int",
            validators: [
                AnyPreferenceValidator(validator: PreferenceValueValidator<Int>(min: 5, max: 10, validationMessage: "first")),
                AnyPreferenceValidator(validator: PreferenceValueValidator<Int>(min: 0, max: 10, validationMessage: "passes")),
                AnyPreferenceValidator(validator: PreferenceValueValidator<Int>(min: 3, max: 10, validationMessage: "last"))
            ],
            userDefaults: defaults,
            userDefaultsKey: key
        )

        #expect(item.lastErrorMessageIfInvalid(value: 1) == "last")
        #expect(item.lastErrorMessageIfInvalid(value: 4) == "first")
        #expect(item.lastErrorMessageIfInvalid(value: 7) == nil)
    }

    @Test("A failing validator without a message is reported as valid")
    func failingValidatorWithoutMessage() {
        let item = PreferencesIntItem(
            title: "Int",
            validators: [AnyPreferenceValidator(validator: PreferenceValueValidator<Int>(min: 5, max: 10))],
            userDefaults: defaults,
            userDefaultsKey: key
        )

        // Pins current behaviour: `compactMap` drops the nil message, so the invalid value has no error.
        #expect(item.lastErrorMessageIfInvalid(value: 1) == nil)
    }

    // MARK: - Equality

    @Test("Items compare by their current value, not by name")
    func equalityComparesValues() {
        let otherDefaults = IsolatedUserDefaults()
        let first = PreferencesTextItem(
            title: "First",
            userDefaults: defaults,
            userDefaultsKey: key
        )
        let second = PreferencesTextItem(
            title: "Second",
            userDefaults: otherDefaults.defaults,
            userDefaultsKey: key
        )

        #expect(first == second)
        first.change(to: "changed")
        #expect(first != second)
    }

    @Test("Picker items compare by the description of their value")
    func pickerEquality() {
        var firstValue: any PickerValue = TestPickerValue.first
        let first = PreferencesPickerItem(
            title: "First",
            values: TestPickerValue.allCases,
            setter: { firstValue = $0 },
            getter: { firstValue }
        )
        let second = PreferencesPickerItem(
            title: "Second",
            values: TestPickerValue.allCases,
            setter: { _ in },
            getter: { TestPickerValue.first }
        )

        #expect(first == second)
        first.change(to: TestPickerValue.second)
        #expect(first != second)
        #expect(first.values.count == 2)
    }
}

// MARK: - Helpers

private final class Recorder {
    var values: [String] = []
}

private struct TestPreferenceItem: PreferenceItem {

    let name = "Test"
    let description: String? = nil
    let validators: [AnyPreferenceValidator<String>] = []
    let userDefaults: UserDefaults
    let userDefaultsKey: String?
    let recorder = Recorder()

    var setter: (String) -> () { { [recorder] in recorder.values.append($0) } }
    var getter: () -> String { { [recorder] in recorder.values.last ?? "" } }

    init(defaults: UserDefaults, key: String) {
        userDefaults = defaults
        userDefaultsKey = key
    }

    static func == (lhs: TestPreferenceItem, rhs: TestPreferenceItem) -> Bool {
        lhs.getter() == rhs.getter()
    }
}

private enum TestPickerValue: String, CaseIterable, CustomStringConvertible {
    case first
    case second

    var description: String { rawValue }
}
