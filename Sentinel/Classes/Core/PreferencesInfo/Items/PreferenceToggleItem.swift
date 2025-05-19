//
//  PreferenceToggleItem.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation

@available(*, deprecated, renamed: "PreferenceToggleItem", message: "Usage of the ToggleToolItem is not recommended due to the plan for deprecation. Use PreferenceToggleItem instead.")
public typealias ToggleToolItem = PreferenceToggleItem

/// Item which will create a preferences view with a toggle button
public struct PreferenceToggleItem: PreferenceItem {

    // MARK: - Public properties

    public let name: String
    public let description: String?
    public let setter: (Bool) -> ()
    public let getter: () -> Bool
    public let validators: [AnyPreferenceValidator<Bool>]
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?

    // MARK: - Init

    public init(
        title: String,
        description: String? = nil,
        validators: [AnyPreferenceValidator<Bool>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String
    ) {
        self.name = title
        self.description = description
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        self.validators = validators
        setter = { userDefaults.set($0, forKey: userDefaultsKey) }
        getter = { userDefaults.bool(forKey: userDefaultsKey)}
    }

    public init(
        title: String,
        description: String? = nil,
        validators: [AnyPreferenceValidator<Bool>] = [],
        setter: @escaping (Bool) -> (),
        getter: @escaping () -> Bool
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
    func change(to value: Bool) {
        store(newValue: value)
    }
}

extension PreferenceToggleItem: Equatable {

    public static func == (lhs: PreferenceToggleItem, rhs: PreferenceToggleItem) -> Bool {
        lhs.getter() == rhs.getter()
    }
}
