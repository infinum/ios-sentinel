//
//  OptionSwitchItem.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import Foundation

public struct ToggleToolItem {
    let title: String
    let setter: ((Bool) -> ())?
    let getter: (() -> Bool)?
    let userDefaults: UserDefaults
    let userDefaultsKey: String?

    public init(
        title: String,
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String
    ) {
        self.title = title
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        setter = nil
        getter = nil
    }

    public init(
        title: String,
        setter: @escaping (Bool) -> (),
        getter: @escaping () -> Bool
    ) {
        self.title = title
        self.getter = getter
        self.setter = setter
        userDefaults = .standard
        userDefaultsKey = nil
    }
}

// MARK: - Extensions

// MARK: - Equatable and Identifiable conformance

extension ToggleToolItem: Equatable, Identifiable {

    public var id: String { title }

    public static func == (lhs: ToggleToolItem, rhs: ToggleToolItem) -> Bool {
        lhs.title == rhs.title
    }
}

// MARK: - Helpres

extension ToggleToolItem {

    func change(to value: Bool) {
        if let userDefaultsKey {
            userDefaults.set(value, forKey: userDefaultsKey)
        }
        setter?(value)
    }

    func loadStoredValue() -> Bool {
        guard let key = userDefaultsKey,
              let value = userDefaults.object(forKey: key) as? Bool
        else { return getter?() ?? false }
        return value
    }
}
