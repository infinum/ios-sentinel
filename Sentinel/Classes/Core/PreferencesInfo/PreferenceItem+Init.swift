//
//  PreferenceItem+Init.swift
//  Sentinel
//
//  Created by Infinum on 12.09.2023..
//

import UIKit

extension PreferenceItem {

    // MARK: - Inferred Value (Must be codable)

    /// Preference as a String. Displays as UITextField.
    ///
    /// - Parameter name: The name of the preference
    /// - Parameter info: Optional additional info like instructions, format etc.
    /// - Parameter userDefaultsKey: The key under which this preference is saved in UserDefaults
    /// - Parameter userDefaults: Optionally define a different suite of UserDefaults (standard by default).
    /// - Parameter onDidSet: Optional execution block once the value is changed.
    public convenience init<T: Codable>(
        type: T.Type,
        name: String,
        info: String? = "",
        validator: (T) -> Bool = { _ in return true },
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((T?) -> Void)?
    ) {
        var inputType: InputType
        switch type {
        case is String.Type: inputType = .text
        case is Int.Type: inputType = .integer
        case is Double.Type: inputType = .double
        case is Bool.Type: inputType = .bool
        default:
            inputType = .text
            assertionFailure("Unsupported type: \(T.self))! Choose String, Int, Double.")
        }
        self.init(
            inputType: inputType,
            name: name,
            info: info,
            validator: { data in
                guard let value = try? JSONDecoder().decode(T.self, from: data) else {
                    assertionFailure("Data mismatch! \(T.self)")
                    return false
                }
                return validator(value)
            },
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            onDidSet: { data in
                guard let data else {
                    onDidSet?(nil)
                    return
                }
                guard let value = try? JSONDecoder().decode(T.self, from: data) else {
                    assertionFailure("Data mismatch! \(T.self)")
                    return
                }
                onDidSet?(value)
            }
        )
    }
    // MARK: - String Enumeration

    /// Preference as an enum. Displayed as a button with context menu.
    /// The enum must conform to `RawRepresentable` as `String` or `Int`. Must be `CaseIterable`
    ///
    /// - Parameter name: The name of the preference
    /// - Parameter info: Optional additional info like instructions, format etc.
    /// - Parameter userDefaultsKey: The key under which this preference is saved in UserDefaults
    /// - Parameter userDefaults: Optionally define a different suite of UserDefaults (standard by default).
    /// - Parameter onDidSet: Optional execution block once the value is changed.
    public convenience init<T: Codable & RawRepresentable & CaseIterable> (
        enumType: T.Type,
        name: String,
        info: String? = "",
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((T?) -> Void)?
    ) where T.RawValue == String {
        self.init(
            inputType: .enumeration(allCases: T.allCases.map(\.rawValue)),
            name: name,
            info: info,
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            onDidSet: { data in
                guard let data else {
                    onDidSet?(nil)
                    return
                }
                guard let value = try? JSONDecoder().decode(T.self, from: data) else {
                    assertionFailure("Data mismatch! \(T.self)")
                    return
                }
                onDidSet?(value)
            }
        )
    }
}
