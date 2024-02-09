//
//  OptionGenericItem.swift
//  Sentinel
//
//  Created by Infinum on 04.09.2023..
//

import UIKit

struct PreferenceItemStoredValue: Codable {
    var type: PreferenceItem.InputType
    var encodedJson: String?
}

@objcMembers
public class PreferenceItem: NSObject {

    enum InputError: LocalizedError {
        case formatError
        case outOfRange
        case enumCaseNotFound
    }

    /// Input type of preference. Defines what UI control to display.
    enum InputType: Codable {
        /// String input
        case text
        /// Boolean input: "true" or "false"
        case bool
        /// Integer input
        case integer
        /// Double input
        case double
        /// Enum input, as a RawRepresentable with either String or Int as type.
        case enumeration(allCases: [String])
    }

    /// Name of the item
    let name: String

    /// More information. E.g. instructions, format etc.
    let info: String?

    /// The type of this preference
    let type: InputType

    func loadStoredValue<T: Decodable>(type: T.Type) -> T? {
        guard let userDefaultsKey, let data = userDefaults.data(forKey: userDefaultsKey) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func loadStoredValue<T: Decodable>() -> T? {
        guard let userDefaultsKey, let data = userDefaults.data(forKey: userDefaultsKey) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func saveStoredValue<T: Encodable>(_ newValue: T?) {
        guard let userDefaultsKey else { return }
        guard let newValue else {
            userDefaults.set(nil, forKey: userDefaultsKey)
            return
        }
        guard let data = try? JSONEncoder().encode(newValue) else { return }
        userDefaults.set(data, forKey: userDefaultsKey)
    }

    // MARK: - Private Properties

    private let userDefaults: UserDefaults
    private let userDefaultsKey: String?
    private let onDidSet: ((Data?) -> Void)?
    private let validator: ((Data) -> Bool)? = nil
    
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
        inputType: InputType,
        name: String,
        info: String? = "",
        validator: (Data) -> Bool = { !$0.isEmpty },
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((Data?) -> Void)?
    ) {
        self.name = name
        self.info = info
        self.type = inputType
        self.userDefaultsKey = userDefaultsKey
        self.userDefaults = userDefaults
        self.onDidSet = nil
    }

    // MARK: - Public Initializers

    /// Please see `PreferenceItem+Init` for all the public initiailzers.

    // MARK: - Internal Methods

    func didChangeInputValue(newValue: String?) throws {
        try store(newValue: newValue)
    }

    func store(newValue: String?) throws {
        guard var newValue else {
            saveStoredValue(String?.none)
            return
        }
        switch type {
        case .bool:
            saveStoredValue(newValue.boolValue)
        case .text:
            saveStoredValue(newValue)
        case .integer:
            guard let number = Int(newValue) else {
                throw InputError.formatError
            }
            saveStoredValue(number)
        case .double:
            newValue = newValue.replacingOccurrences(of: ",", with: ".") // Swift only recognizes dot as decimal separator.
            guard let value = Double(newValue) else {
                throw InputError.formatError
            }
            saveStoredValue(value)
        case .enumeration(let allCases):
            print(allCases)
            break // TODO: ?????
            /*
            guard allCases.contains(where: { $0.partiallyMatches(string: newValue) }) else {
                throw InputError.enumCaseNotFound
            }
            value = newValue
            */
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

    @available(*, deprecated, message: "Please use .init(type:name:) method")
    public convenience init(
        name: String,
        setter: ((Bool) -> ())?,
        getter: (() -> (Bool))?,
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String?
    ) {
        self.init(
            type: Bool.self,
            name: name,
            info: "",
            validator: { _ in return true },
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            onDidSet: { value in
                if let value {
                    setter?(value)
                }
            }
        )
    }
}

// MARK: - Other Extensions

extension String {
    var boolValue: Bool {
        return (self as NSString).boolValue
    }
}

extension Double {
    var asString: String { .init(self) }
}

extension Int {
    var asString: String { .init(self) }
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
