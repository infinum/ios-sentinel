//
//  PreferenceBoolItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

public struct PreferenceBoolItem: PreferenceItem {

    // MARK: - Public properties

    public let name: String
    public let setter: (Bool) -> ()
    public let getter: () -> Bool
    public let validators: [AnyPreferenceValidator<Bool>]
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?

    // MARK: - Init

    public init(
        title: String,
        validators: [AnyPreferenceValidator<Bool>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String
    ) {
        self.name = title
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        self.validators = validators
        setter = { userDefaults.set($0, forKey: userDefaultsKey) }
        getter = { userDefaults.bool(forKey: userDefaultsKey)}
    }

    public init(
        title: String,
        validators: [AnyPreferenceValidator<Bool>] = [],
        setter: @escaping (Bool) -> (),
        getter: @escaping () -> Bool
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
    func change(to value: Bool) {
        store(newValue: value)
    }
}

extension PreferenceBoolItem: Equatable {
    public static func == (lhs: PreferenceBoolItem, rhs: PreferenceBoolItem) -> Bool {
        lhs.getter() == rhs.getter()
    }
}
