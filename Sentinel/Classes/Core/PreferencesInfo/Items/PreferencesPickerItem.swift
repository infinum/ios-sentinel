//
//  PreferencesPickerItem.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

public typealias PickerValue = RawRepresentable & CustomStringConvertible

/// Item which will create a preferences view with a picker
public struct PreferencesPickerItem: PreferenceItem {

    // MARK: - Public properties

    public let name: String
    public var description: String?
    public let setter: (any PickerValue) -> ()
    public let getter: () -> any PickerValue
    public let validators: [AnyPreferenceValidator<any PickerValue>]
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?

    // MARK: - Internal properties

    let values: [any PickerValue]

    // MARK: - Init

    public init(
        title: String,
        description: String? = nil,
        values: [any PickerValue],
        setter: @escaping (any PickerValue) -> (),
        getter: @escaping () -> any PickerValue,
        validators: [AnyPreferenceValidator<any PickerValue>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String? = nil
    ) {
        name = title
        self.description = description
        self.values = values
        self.getter = getter
        self.setter = setter
        self.validators = validators
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
    }

    // MARK: - Internal methods

    /// Changes current enabled state of the feature.
    ///
    /// This is mostly used inside option switch module
    /// but it is also exposed for external change.
    func change(to value: any PickerValue) {
        store(newValue: value)
    }
}

extension PreferencesPickerItem {

    public static func == (lhs: PreferencesPickerItem, rhs: PreferencesPickerItem) -> Bool {
        lhs.getter().description == rhs.getter().description
    }
}
