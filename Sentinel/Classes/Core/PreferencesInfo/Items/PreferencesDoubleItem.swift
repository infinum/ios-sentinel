//
//  PreferencesDoubleItem.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

/// Item which will create a preferences view with a title, and a text editor which will only save Double values
public struct PreferencesDoubleItem: PreferenceItem {

    // MARK: - Public properties

    public let name: String
    public let setter: (Double) -> ()
    public let getter: () -> Double
    public let validators: [AnyPreferenceValidator<Double>]
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?

    // MARK: - Init

    public init(
        title: String,
        validators: [AnyPreferenceValidator<Double>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String
    ) {
        self.name = title
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        self.validators = validators
        setter = { userDefaults.set($0, forKey: userDefaultsKey) }
        getter = { userDefaults.double(forKey: userDefaultsKey) }
    }

    public init(
        title: String,
        validators: [AnyPreferenceValidator<Double>] = [],
        setter: @escaping (Double) -> (),
        getter: @escaping () -> Double
    ) {
        self.name = title
        self.getter = getter
        self.setter = setter
        self.validators = validators
        userDefaults = .standard
        userDefaultsKey = nil
    }

    // MARK: - Internal methods

    /// Changes current enabled state of the feature.
    ///
    /// This is mostly used inside option switch module
    /// but it is also exposed for external change.
    func change(to value: Double) {
        store(newValue: value)
    }
}

extension PreferencesDoubleItem: Equatable {

    public static func == (lhs: PreferencesDoubleItem, rhs: PreferencesDoubleItem) -> Bool {
        lhs.getter() == rhs.getter()
    }
}
