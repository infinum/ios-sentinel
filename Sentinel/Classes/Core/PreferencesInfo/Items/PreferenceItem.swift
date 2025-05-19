//
//  PreferenceItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

public protocol PreferenceItem: Identifiable, Equatable {
    associatedtype T

    /// Name of the item
    var name: String { get }

    /// Description of the item
    var description: String? { get }

    /// This function is called when value is changed.
    ///
    /// It should be used to change the current variable value.
    var setter: (T) -> () { get }

    /// This function is called when value needs to be read.
    ///
    /// It should be used to provide the current variable value.
    var getter: () -> T { get }

    /// Array of validators used to define validation rules..
    var validators: [AnyPreferenceValidator<T>] { get }

    /// Default storage used for storing information if the key is provided.
    var userDefaults: UserDefaults { get }

    /// Defines key for storing information.
    ///
    /// If the value is not provided, the information won't be stored.
    var userDefaultsKey: String? { get }
}

// MARK: - Private methods

extension PreferenceItem {

    func lastErrorMessageIfInvalid(value: T) -> String? {
        validators
            .compactMap { $0.validate(value: value) ? nil : $0.validationMessage }
            .last
    }

    func store(newValue: T) {
        if let key = userDefaultsKey {
            userDefaults.set(newValue, forKey: key)
        }
        setter(newValue)
    }

    func loadStoredValue() {
        guard let key = userDefaultsKey,
              let value = userDefaults.object(forKey: key) as? T
        else { return }
        setter(value)
    }
}

extension PreferenceItem {
    public var id: String { name }
}
