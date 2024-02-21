//
//  OptionSwitchItem.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

/// Deprecated. Previously named `OptionSwitchItem` and only supported switch/boolean.
@available(*, deprecated, renamed: "PreferenceSwitchItem")
public typealias OptionSwitchItem = PreferenceSwitchItem

/// Provides option to change enabled state of the feature.
@objcMembers
public class PreferenceSwitchItem: NSObject {
    
    // MARK: - Public properties
    
    public let name: String
    public let setter: (Bool) -> ()
    public let getter: () -> (Bool)
    public let validator: ((Bool) -> Bool)?
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?

    // MARK: - Lifecycle
    
    public init(
        name: String,
        setter: @escaping (Bool) -> (),
        getter: @escaping () -> (Bool),
        validator: ((Bool) -> Bool)? = nil,
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String?
    ) {
        self.name = name
        self.setter = setter
        self.getter = getter
        self.validator = validator
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        super.init()
        loadStoredValue()
    }
    
    // MARK: - Internal methods
    
    /// Changes current enabled state of the feature.
    ///
    /// This is mostly used inside option switch module
    /// but it is also exposed for external change.
    @objc(changeToValue:)
    func change(to value: Bool) {
        store(newValue: value)
    }
}

extension PreferenceSwitchItem: PreferenceItem {
    
    public func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PreferenceSwitchTableViewCell.self, for: indexPath)
        cell.configure(with: self)
        return cell
    }
    
    public func register(at tableView: UITableView) {
        tableView.registerNib(cellOfType: PreferenceSwitchTableViewCell.self)
    }
}
