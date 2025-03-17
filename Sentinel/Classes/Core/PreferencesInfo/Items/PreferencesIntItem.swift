//
//  PreferencesIntItem.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

public struct PreferencesIntItem: PreferenceItem {

    // MARK: - Public properties

    public let name: String
    public let setter: (Int) -> ()
    public let getter: () -> Int
    public let validators: [AnyPreferenceValidator<Int>]
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?

    // MARK: - Lifecycle


    public init(
        title: String,
        validators: [AnyPreferenceValidator<Int>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String
    ) {
        self.name = title
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        self.validators = validators
        setter = { userDefaults.set($0, forKey: userDefaultsKey) }
        getter = { userDefaults.integer(forKey: userDefaultsKey) }
    }

    public init(
        title: String,
        validators: [AnyPreferenceValidator<Int>] = [],
        setter: @escaping (Int) -> (),
        getter: @escaping () -> Int
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
    func change(to value: Int) {
        store(newValue: value)
    }
}

extension PreferencesIntItem {

    public static func == (lhs: PreferencesIntItem, rhs: PreferencesIntItem) -> Bool {
        lhs.getter() == rhs.getter()
    }
}
