//
//  PreferenceTextViewTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing
@testable import Sentinel

@Suite("Preference text field validation")
struct PreferenceTextViewTests {

    private let isolatedDefaults = IsolatedUserDefaults()

    @Test("Numeric fields reject text that can't be converted")
    func numericFieldsRejectText() {
        let views = [
            PreferenceTextView(item: PreferencesIntItem(title: "Int", userDefaults: isolatedDefaults.defaults, userDefaultsKey: "int")),
            PreferenceTextView(item: PreferencesFloatItem(title: "Float", userDefaults: isolatedDefaults.defaults, userDefaultsKey: "float")),
            PreferenceTextView(item: PreferencesDoubleItem(title: "Double", description: nil, userDefaults: isolatedDefaults.defaults, userDefaultsKey: "double"))
        ]

        for view in views {
            #expect(view.hasErrorMessage("abc") == "Can not convert value", "\(view.title)")
            #expect(view.hasErrorMessage("5") == nil, "\(view.title)")
        }
    }

    @Test("Converted values go through the item's validators")
    func convertedValuesAreValidated() {
        let item = PreferencesIntItem(
            title: "Int",
            validators: [
                AnyPreferenceValidator(
                    validator: PreferenceValueValidator<Int>(
                        min: 3,
                        max: 10,
                        validationMessage: "3 to 10"
                    )
                )
            ],
            userDefaults: isolatedDefaults.defaults,
            userDefaultsKey: "int"
        )
        let view = PreferenceTextView(item: item)

        #expect(view.hasErrorMessage("2") == "3 to 10")
        #expect(view.hasErrorMessage("4") == nil)
    }

    @Test("Valid input is stored, invalid input is not")
    func onValueChangedStoresValidInput() {
        let item = PreferencesIntItem(
            title: "Int",
            userDefaults: isolatedDefaults.defaults,
            userDefaultsKey: "int"
        )
        let view = PreferenceTextView(item: item)

        view.onValueChanged("12")
        #expect(item.getter() == 12)
        view.onValueChanged("abc")
        #expect(item.getter() == 12)
        #expect(view.getter() == "12")
    }

    @Test("Text fields validate the raw string")
    func textFieldValidation() {
        let item = PreferencesTextItem(
            title: "Text",
            validators: [
                AnyPreferenceValidator(
                    validator: PreferenceCountValidator<String>(
                        min: 2,
                        max: nil,
                        validationMessage: "Too short"
                    )
                )
            ],
            userDefaults: isolatedDefaults.defaults,
            userDefaultsKey: "text"
        )
        let view = PreferenceTextView(item: item)

        #expect(view.hasErrorMessage("a") == "Too short")
        #expect(view.hasErrorMessage("ab") == nil)
    }
}
