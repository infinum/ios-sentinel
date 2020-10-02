//
//  OptionSwitchItem.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import Foundation

public class OptionSwitchItem {
    
    // MARK: - Public properties
    
    let name: String
    let setter: (Bool) -> ()
    let getter: () -> (Bool)
    
    // MARK: - Private properties
    
    private let userDefaults: UserDefaults
    private let userDefaultsKey: String?

    // MARK: - Lifecycle
    
    public init(
        name: String,
        setter: @escaping (Bool) -> (),
        getter: @escaping () -> (Bool),
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String?
    ) {
        self.name = name
        self.setter = setter
        self.getter = getter
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        loadStoredValue()
    }
    
    // MARK: - Public methods
    
    func change(to value: Bool) {
        store(newValue: value)
    }
}

// MARK: - Private methods

private extension OptionSwitchItem {
    
    func store(newValue: Bool) {
        if let key = userDefaultsKey {
            userDefaults.set(newValue, forKey: key)
        }
        setter(newValue)
    }
    
    func loadStoredValue() {
        guard
            let key = userDefaultsKey,
            let value = userDefaults.object(forKey: key) as? Bool
        else { return }
        setter(value)
    }
}
