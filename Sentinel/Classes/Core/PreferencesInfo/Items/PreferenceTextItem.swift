//
//  PreferenceTextItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

public struct PreferenceTextItem: PreferenceItem {

    // MARK: - Public properties

    public let name: String
    public let setter: (String) -> ()
    public let getter: () -> String
    public let validators: [AnyPreferenceValidator<String>]
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?

    // MARK: - Lifecycle


    public init(
        title: String,
        validators: [AnyPreferenceValidator<String>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String
    ) {
        self.name = title
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        self.validators = validators
        setter = { userDefaults.set($0, forKey: userDefaultsKey) }
        getter = { userDefaults.string(forKey: userDefaultsKey) ?? "no-value" }
    }

    public init(
        title: String,
        validators: [AnyPreferenceValidator<String>] = [],
        setter: @escaping (String) -> (),
        getter: @escaping () -> String
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
    func change(to value: String) {
        store(newValue: value)
    }

    public static func == (lhs: PreferenceTextItem, rhs: PreferenceTextItem) -> Bool {
        lhs.getter() == rhs.getter()
    }
}
