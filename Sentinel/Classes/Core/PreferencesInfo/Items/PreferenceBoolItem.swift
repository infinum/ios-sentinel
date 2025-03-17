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

    // MARK: - Lifecycle

    public init(
        title: String,
        setter: @escaping (Bool) -> Void,
        getter: @escaping () -> Bool,
        validators: [AnyPreferenceValidator<Bool>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String? = nil
    ) {
        self.name = title
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
    func change(to value: Bool) {
        store(newValue: value)
    }

    public static func == (lhs: PreferenceBoolItem, rhs: PreferenceBoolItem) -> Bool {
        lhs.getter() == rhs.getter()
    }
}
