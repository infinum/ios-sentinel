//
//  PreferencesFloatItem.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

/// Item which will create a preferences view with a title, and a text editor which will only save Float values
public struct PreferencesFloatItem: PreferenceItem {

    // MARK: - Public properties

    public let name: String
    public let setter: (Float) -> ()
    public let getter: () -> Float
    public let validators: [AnyPreferenceValidator<Float>]
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?

    // MARK: - Lifecycle

    public init(
        title: String,
        validators: [AnyPreferenceValidator<Float>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String
    ) {
        self.name = title
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        self.validators = validators
        setter = { userDefaults.set($0, forKey: userDefaultsKey) }
        getter = { userDefaults.float(forKey: userDefaultsKey) }
    }

    public init(
        title: String,
        validators: [AnyPreferenceValidator<Float>] = [],
        setter: @escaping (Float) -> (),
        getter: @escaping () -> Float
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
    func change(to value: Float) {
        store(newValue: value)
    }
}

extension PreferencesFloatItem: Equatable {

    public static func == (lhs: PreferencesFloatItem, rhs: PreferencesFloatItem) -> Bool {
        lhs.getter() == rhs.getter()
    }
}
