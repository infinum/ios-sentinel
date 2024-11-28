//
//  TextEditingTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 31/07/2020.
//

import UIKit
import SwiftUI

@objcMembers
public final class TextEditingTool: NSObject, Tool {

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
        super.init()
        loadStoredValue()
    }

    public var content: any View {
        TextEditingToolView(viewModel: .init(value: getter(), title: name, didPressSave: store(newValue:)))
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
