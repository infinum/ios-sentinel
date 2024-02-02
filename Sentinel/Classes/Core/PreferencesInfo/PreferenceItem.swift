//
//  OptionGenericItem.swift
//  Sentinel
//
//  Created by Infinum on 04.09.2023..
//

import UIKit

@objcMembers
public class PreferenceItem: NSObject {

    enum InputError: LocalizedError {
        case formatError
        case outOfRange
        case enumCaseNotFound
    }

    /// Input type of preference. Defines what UI control to display.
    enum InputType {
        /// String input
        case text
        /// Boolean input: "true" or "false"
        case bool
        /// Integer input
        case integer
        /// Double input
        case double
        /// Enum input, as a RawRepresentable with either String or Int as type.
        case enumeration(allCases: [any RawRepresentable])
    }

    /// Name of the item
    let name: String

    /// More information. E.g. instructions, format etc.
    let info: String?

    /// The type of this preference
    let type: InputType

    /// Value, saved as string.
    var value: String? {
        get {
            guard let userDefaultsKey else { return nil }
            return userDefaults.string(forKey: userDefaultsKey) }
        set {
            guard let userDefaultsKey else { return }
            userDefaults.set(newValue, forKey: userDefaultsKey)
        }
    }

    // MARK: - Private Properties

    private let userDefaults: UserDefaults
    private let userDefaultsKey: String?
    private let onDidSet: ((String?) -> Void)?
    private let validator: ((String) -> Bool)? = nil

    // MARK: - Methods

    /// Initializes and returns a new Preference.
    ///
    /// - Parameter name: The name of the preference
    /// - Parameter info: Optional additional info like instructions, format etc.
    /// - Parameter type: The type of this preference.
    /// - Parameter userDefaultsKey: The key under which this preference is saved in UserDefaults
    /// - Parameter userDefaults: Optionally define a different suite of UserDefaults (standard by default).
    /// - Parameter onDidSet: Optional execution block once the value is changed.
    init(
        name: String,
        info: String? = "",
        type: InputType,
        validator: (String) -> Bool = { !$0.isEmpty },
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((String?) -> Void)?
    ) {
        self.name = name
        self.info = info
        self.type = type
        self.userDefaultsKey = userDefaultsKey
        self.userDefaults = userDefaults
        self.onDidSet = onDidSet
    }

    // MARK: - Public Initializers

    /// Please see `PreferenceItem+Init` for all the public initiailzers.

    // MARK: - Internal Methods

    func didChangeInputValue(newValue: String?) throws {
        try store(newValue: newValue)
    }

    func store(newValue: String?) throws {
        guard var newValue else {
            value = nil
            return
        }
        switch type {
        case .bool:
            value = String(newValue.boolValue)
        case .text:
            value = newValue
        case .integer:
            guard let number = Int(newValue) else {
                throw InputError.formatError
            }
            value = String(number)
        case .double:
            newValue = newValue.replacingOccurrences(of: ",", with: ".") // Swift only recognizes dot as decimal separator.
            guard let number = Double(newValue) else {
                throw InputError.formatError
            }
            value = String(number)
        case .enumeration(let allCases):
            guard allCases.contains(where: { $0.partiallyMatches(string: newValue) }) else {
                throw InputError.enumCaseNotFound
            }
            value = newValue
        }
    }

    /// Additional description for this preference
    var rangeDescription: String? {
        nil // TODO: Fix --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    }
}

// MARK: - Deprecated Methods

/// Deprecated. Previously named "OptionSwitchItem" and only supported switch/boolean.
@available(*, deprecated, renamed: "OptionGenericItem")
public typealias OptionSwitchItem = PreferenceItem

extension PreferenceItem {

    @available(*, deprecated, message: "Please use the default init method using 'bool' as the input type")
    public convenience init(
        name: String,
        setter: ((Bool) -> ())?,
        getter: (() -> (Bool))?,
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String?
    ) {
        self.init(
            name: name,
            info: "",
            type: .bool,
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults) { newValue in
                if let setter, let newValue {
                    setter(newValue.boolValue)
                }
            }
    }
}

// MARK: - Other Extensions

extension String {
    var boolValue: Bool {
        return (self as NSString).boolValue
    }
}

private extension RawRepresentable {

    /// Indicates whether this case can be matched via its String or Int raw value
    func partiallyMatches(string: String?) -> Bool {
        guard let string else { return false }
        switch rawValue {
        case let _value as Int: return _value == Int(string)
        case let _value as String: return _value == string
        default: return false
        }
    }
}
