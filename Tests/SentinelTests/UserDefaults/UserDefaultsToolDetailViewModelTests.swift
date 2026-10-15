//
//  UserDefaultsToolDetailViewModelTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("User defaults editing")
struct UserDefaultsToolDetailViewModelTests {

    private let isolatedDefaults = IsolatedUserDefaults()
    private var defaults: UserDefaults { isolatedDefaults.defaults }
    private let key = "sentinel.tests.key"

    @Test("Saving a String keeps it a String")
    func saveString() {
        defaults.set("old", forKey: key)

        save("new")

        #expect(defaults.string(forKey: key) == "new")
    }

    @Test("Saving a Bool keeps it a Bool")
    func saveBool() {
        defaults.set(true, forKey: key)

        save("false")

        #expect(defaults.object(forKey: key) as? Bool == false)
    }

    @Test("Saving Data decodes base64")
    func saveData() {
        defaults.set(Data([0x01]), forKey: key)

        save(Data("hello".utf8).base64EncodedString())

        #expect(defaults.data(forKey: key) == Data("hello".utf8))
    }

    @Test("Saving a Double keeps it a Double")
    func saveDouble() {
        defaults.set(1.5, forKey: key)

        save("2.75")

        #expect(defaults.double(forKey: key) == 2.75)
    }

    @Test("Saving an Int keeps it an integer")
    func saveInt() throws {
        defaults.set(42, forKey: key)

        save("7")

        #expect(defaults.integer(forKey: key) == 7)
        let number = try #require(defaults.object(forKey: key) as? NSNumber)
        withKnownIssue("An NSNumber holding an Int also matches `is Double`, which is checked first, so the Int is stored as a Double") {
            #expect(!CFNumberIsFloatType(number))
        }
    }

    @Test("Saving a string array splits on commas")
    func saveStringArray() {
        defaults.set(["a", "b"], forKey: key)

        save("x,y,z")

        #expect(defaults.stringArray(forKey: key) == ["x", "y", "z"])
    }

    @Test("A value that can't be converted is ignored, but the callback still fires")
    func unconvertibleValue() {
        defaults.set(true, forKey: key)
        var callbacks = 0
        let viewModel = makeViewModel(value: "not a bool") { callbacks += 1 }

        viewModel.didPressSave()

        #expect(defaults.bool(forKey: key))
        #expect(callbacks == 1)
    }

    @Test("A missing key is not created on save")
    func missingKey() {
        var callbacks = 0
        let viewModel = makeViewModel(value: "value") { callbacks += 1 }

        viewModel.didPressSave()

        #expect(defaults.object(forKey: key) == nil)
        #expect(callbacks == 1)
    }

    @Test("Deleting removes the key and calls the callback")
    func delete() {
        defaults.set("value", forKey: key)
        var callbacks = 0
        let viewModel = makeViewModel(value: "value") { callbacks += 1 }

        viewModel.didPressDelete()

        #expect(defaults.object(forKey: key) == nil)
        #expect(callbacks == 1)
    }
}

private extension UserDefaultsToolDetailViewModelTests {

    func makeViewModel(value: String, didUpdate: (() -> Void)? = nil) -> UserDefaultsToolDetailViewModel {
        UserDefaultsToolDetailViewModel(
            value: value,
            title: key,
            userDefaults: defaults,
            didUpdateProperty: didUpdate
        )
    }

    func save(_ value: String) {
        makeViewModel(value: value).didPressSave()
    }
}
