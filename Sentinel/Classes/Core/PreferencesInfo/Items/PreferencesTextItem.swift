//
//  PreferencesTextItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

/// Item which will create a preferences view with a title, and a text editor
public struct PreferencesTextItem: PreferenceItem {

    // MARK: - Public properties

    public let name: String
    public var description: String?
    public let setter: (String) -> ()
    public let getter: () -> String
    public let validators: [AnyPreferenceValidator<String>]
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?

    // MARK: - Init

    public init(
        title: String,
        description: String? = nil,
        validators: [AnyPreferenceValidator<String>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String
    ) {
        self.name = title
        self.description = description
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        self.validators = validators
        setter = { userDefaults.set($0, forKey: userDefaultsKey) }
        getter = { userDefaults.string(forKey: userDefaultsKey) ?? "no-value" }
    }

    public init(
        title: String,
        description: String? = nil,
        validators: [AnyPreferenceValidator<String>] = [],
        setter: @escaping (String) -> (),
        getter: @escaping () -> String
    ) {
        self.name = title
        self.description = description
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
}

extension PreferencesTextItem {

    public static func == (lhs: PreferencesTextItem, rhs: PreferencesTextItem) -> Bool {
        lhs.getter() == rhs.getter()
    }
}
