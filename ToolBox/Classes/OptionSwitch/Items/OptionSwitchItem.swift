//
//  OptionSwitchItem.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import Foundation

/// Provides option to change enabled state of the feature.
@objcMembers
public class OptionSwitchItem: NSObject {
    
    // MARK: - Public properties
    
    /// Name of the item
    let name: String
    /// This function is called when value is changed.
    ///
    /// It should be used to change the current variable value.
    let setter: (Bool) -> ()
    /// This function is called when value needs to be read.
    ///
    /// It should be used to provide the current variable value.
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
        super.init()
        loadStoredValue()
    }
    
    // MARK: - Public methods
    
    /// Changes current enabled state of the feature.
    ///
    /// This is mostly used inside option switch module
    /// but it is also exposed for external change.
    @objc(changeToValue:)
    func change(to value: Bool) {
        store(newValue: value)
    }
}

extension OptionSwitchItem: ToolTableItem {
    
    public func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: OptionSwitchTableViewCell.self, for: indexPath)
        cell.configure(with: self)
        return cell
    }
    
    public func register(at tableView: UITableView) {
        tableView.registerNib(cellOfType: OptionSwitchTableViewCell.self)
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
        guard let key = userDefaultsKey,
              let value = userDefaults.object(forKey: key) as? Bool
        else { return }
        setter(value)
    }
}
