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
        name: String,
        setter: @escaping (String) -> Void,
        getter: @escaping () -> String,
        validators: [AnyPreferenceValidator<String>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String?
    ) {
        self.name = name
        self.setter = setter
        self.getter = getter
        self.validators = validators
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        loadStoredValue()
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
