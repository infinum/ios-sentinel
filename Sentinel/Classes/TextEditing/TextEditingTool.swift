//
//  TextEditingTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 31/07/2020.
//

import SwiftUI

/// Tool which gives you the ability to edit a property on the fly
///
/// The property can be edited in the UserDefaults or by setting a custom setter/getter
public struct TextEditingTool: Tool {

    // MARK: - Public properties
    
    public let name: String

    // MARK: - Private properties
    
    private let setter: (String) -> Void
    private let getter: () -> String
    private let userDefaults: UserDefaults
    private let userDefaultsKey: String?

    // MARK: - Lifecycle
    
    public init(
        name: String,
        setter: @escaping (String) -> (),
        getter: @escaping () -> (String),
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String? = nil
    ) {
        self.name = name
        self.setter = setter
        self.getter = getter
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        loadStoredValue()
    }
}

// MARK: - UI

public extension TextEditingTool {

    var content: any View {
        TextEditingToolView(viewModel: TextEditingToolViewModel(value: getter(), title: name, didPressSave: store(newValue:)))
    }
}

// MARK: - Internal methods

extension TextEditingTool {
    
    func store(newValue: String) {
        if let key = userDefaultsKey {
            userDefaults.set(newValue, forKey: key)
        }
        setter(newValue)
    }
    
    func loadStoredValue() {
        guard
            let key = userDefaultsKey,
            let value = userDefaults.string(forKey: key)
        else { return }
        setter(value)
    }
    
}
