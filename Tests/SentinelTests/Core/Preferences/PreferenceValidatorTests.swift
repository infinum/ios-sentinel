//
//  PreferenceValidatorTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing
@testable import Sentinel

@Suite("Preference validators")
struct PreferenceValidatorTests {

    // MARK: - PreferenceCountValidator

    @Test(
        "Count validator bounds are inclusive",
        arguments: [
            ("", false),
            ("a", false),
            ("ab", true),
            ("abc", true),
            ("abcd", true),
            ("abcde", false)
        ]
    )
    func countValidatorBounds(value: String, isValid: Bool) {
        let validator = PreferenceCountValidator<String>(min: 2, max: 4)

        #expect(validator.validate(value: value) == isValid)
    }

    @Test("Count validator without bounds accepts anything")
    func countValidatorWithoutBounds() {
        let validator = PreferenceCountValidator<[Int]>(min: nil, max: nil)

        #expect(validator.validate(value: []))
        #expect(validator.validate(value: Array(repeating: 1, count: 1_000)))
    }

    @Test("Count validator with only a minimum or only a maximum")
    func countValidatorOneSided() {
        let minimumOnly = PreferenceCountValidator<String>(min: 3, max: nil)
        let maximumOnly = PreferenceCountValidator<String>(min: nil, max: 1)

        #expect(!minimumOnly.validate(value: "ab"))
        #expect(minimumOnly.validate(value: String(repeating: "a", count: 500)))
        #expect(maximumOnly.validate(value: ""))
        #expect(!maximumOnly.validate(value: "ab"))
    }

    // MARK: - PreferenceValueValidator

    @Test(
        "Value validator bounds are inclusive",
        arguments: [
            (2, false),
            (3, true),
            (7, true),
            (10, true),
            (11, false)
        ]
    )
    func valueValidatorBounds(value: Int, isValid: Bool) {
        let validator = PreferenceValueValidator<Int>(min: 3, max: 10)

        #expect(validator.validate(value: value) == isValid)
    }

    @Test("A missing minimum means zero, so negative values fail")
    func valueValidatorMissingMinimumIsZero() {
        let validator = PreferenceValueValidator<Int>(min: nil, max: 10)

        #expect(validator.validate(value: 0))
        #expect(!validator.validate(value: -1))
    }

    @Test("An Int validator without a maximum accepts large values")
    func intValidatorWithoutMaximum() {
        let validator = PreferenceValueValidator<Int>(min: 0, max: nil)

        #expect(validator.validate(value: Int.max))
    }

    @Test("A Double validator without a maximum accepts large values")
    func doubleValidatorWithoutMaximum() {
        let validator = PreferenceValueValidator<Double>(min: 0, max: nil)

        withKnownIssue("Double(exactly: Int.max) is nil, so a nil maximum makes every value invalid") {
            #expect(validator.validate(value: 1.5))
        }
    }

    @Test("A Float validator without a maximum accepts large values")
    func floatValidatorWithoutMaximum() {
        let validator = PreferenceValueValidator<Float>(min: 0, max: nil)

        withKnownIssue("Float(exactly: Int.max) is nil, so a nil maximum makes every value invalid") {
            #expect(validator.validate(value: 1.5))
        }
    }

    @Test("A Double validator with both bounds works")
    func doubleValidatorWithBounds() {
        let validator = PreferenceValueValidator<Double>(min: 0.5, max: 1.5)

        #expect(validator.validate(value: 1.0))
        #expect(!validator.validate(value: 1.6))
    }

    // MARK: - AnyPreferenceValidator

    @Test("AnyPreferenceValidator forwards the result and the message")
    func typeErasureForwards() {
        let validator = AnyPreferenceValidator(
            validator: PreferenceValueValidator<Int>(
                min: 1,
                max: 2,
                validationMessage: "Out of range"
            )
        )

        #expect(validator.validationMessage == "Out of range")
        #expect(validator.validate(value: 1))
        #expect(!validator.validate(value: 3))
    }
}
