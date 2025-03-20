//
//  PreferenceValidator.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

///
/// Defines validator behavior for preference items.
///
public protocol PreferenceValidator<T> {
    associatedtype T

    ///
    /// Defines custom message which will be shown instead
    /// of default validator message.
    ///
    /// - Returns: Custom validation message.
    ///
    var validationMessage: String? { get }

    ///
    /// Validates the provided value and returns `true`
    /// if value is valid for the provided validator.
    ///
    /// - Parameter value: Value to be validated.
    /// - Returns: `true` if value is valid, `false` otherwise.
    ///
    func validate(value: T) -> Bool
}

///
/// An `AnyPreferenceValidator` instance forwards its
/// operation to a base validator having the same type,
/// hiding the specifics of the underlying validator.
///
public struct AnyPreferenceValidator<T>: PreferenceValidator {

    // MARK: - Public properties

    public let validationMessage: String?

    // MARK: - Private properties

    private let isValid: (T) -> Bool

    // MARK: - Lifecycle

    ///
    /// Instantiates and instance which wraps
    /// the concrete validator.
    ///
    /// - Parameter validator: Concrete validator.
    /// - Returns: Instance of `AnyPreferenceValidator`.
    ///
    public init<V: PreferenceValidator>(validator: V) where V.T == T {
        validationMessage = validator.validationMessage
        isValid = validator.validate(value:)
    }

    // MARK: - Public methods

    public func validate(value: T) -> Bool {
        isValid(value)
    }
}
