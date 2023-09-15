//
//  PreferenceItem+Init.swift
//  Sentinel
//
//  Created by Infinum on 12.09.2023..
//

import UIKit

extension PreferenceItem {

    /// Preference as a String. Displays as UITextField.
    ///
    /// - Parameter name: The name of the preference
    /// - Parameter info: Optional additional info like instructions, format etc.
    /// - Parameter userDefaultsKey: The key under which this preference is saved in UserDefaults
    /// - Parameter userDefaults: Optionally define a different suite of UserDefaults (standard by default).
    /// - Parameter onDidSet: Optional execution block once the value is changed.
    public convenience init(
        textName name: String,
        info: String? = "",
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((String?) -> Void)?
    ) {
        self.init(
            name: name,
            info: info,
            type: .text,
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            onDidSet: { onDidSet?($0) }
        )
    }

    /// Preference as a Boolean. Displayed as a UISwitch.
    ///
    /// - Parameter name: The name of the preference
    /// - Parameter info: Optional additional info like instructions, format etc.
    /// - Parameter min: Optional minimum allowed value
    /// - Parameter max: Optional maximum allowed value
    /// - Parameter userDefaultsKey: The key under which this preference is saved in UserDefaults
    /// - Parameter userDefaults: Optionally define a different suite of UserDefaults (standard by default).
    /// - Parameter onDidSet: Optional execution block once the value is changed.
    public convenience init(
        boolName name: String,
        info: String? = "",
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((Bool) -> Void)?
    ) {
        self.init(
            name: name,
            info: info,
            type: .bool,
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            onDidSet: { onDidSet?($0?.boolValue ?? false) }
        )
    }

    /// Preference as an Int. Displayed as a UITextField.
    ///
    /// - Parameter name: The name of the preference
    /// - Parameter info: Optional additional info like instructions, format etc.
    /// - Parameter min: Optional minimum allowed value
    /// - Parameter max: Optional maximum allowed value
    /// - Parameter userDefaultsKey: The key under which this preference is saved in UserDefaults
    /// - Parameter userDefaults: Optionally define a different suite of UserDefaults (standard by default).
    /// - Parameter onDidSet: Optional execution block once the value is changed.
    public convenience init(
        integerName name: String,
        info: String? = "",
        min: Int? = nil,
        max: Int? = nil,
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((Int?) -> Void)?
    ) {
        self.init(
            name: name,
            info: info,
            type: .integer(min: min, max: max),
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            onDidSet: { onDidSet?($0.flatMap(Int.init)) }
        )
    }

    /// Preference as a Double (decimal). Displayed as a UITextField.
    ///
    /// - Parameter name: The name of the preference
    /// - Parameter info: Optional additional info like instructions, format etc.
    /// - Parameter userDefaultsKey: The key under which this preference is saved in UserDefaults
    /// - Parameter userDefaults: Optionally define a different suite of UserDefaults (standard by default).
    /// - Parameter onDidSet: Optional execution block once the value is changed.
    public convenience init(
        doubleName name: String,
        info: String? = "",
        min: Double? = nil,
        max: Double? = nil,
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((Double?) -> Void)?
    ) {
        self.init(
            name: name,
            info: info,
            type: .double(min: min, max: max),
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            onDidSet: { onDidSet?($0.flatMap(Double.init)) }
        )
    }

    /// Preference as an enum. Displayed as a button with context menu.
    /// The enum must conform to `RawRepresentable` as `String` or `Int`. Must be `CaseIterable`
    ///
    /// - Parameter name: The name of the preference
    /// - Parameter info: Optional additional info like instructions, format etc.
    /// - Parameter userDefaultsKey: The key under which this preference is saved in UserDefaults
    /// - Parameter userDefaults: Optionally define a different suite of UserDefaults (standard by default).
    /// - Parameter onDidSet: Optional execution block once the value is changed.
    public convenience init<T: RawRepresentable & CaseIterable> (
        enumName name: String,
        enumType: T.Type,
        info: String? = "",
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((T?) -> Void)?
    ) where T.RawValue == String {
        self.init(
            name: name,
            info: info,
            type: .enumeration(allCases: T.allCases as! [any RawRepresentable]),
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            onDidSet: { onDidSet?($0.flatMap(T.init(rawValue:))) }
        )
    }

    /// Preference as a enum. Displayed as a button with context menu.
    /// The enum must conform to `RawRepresentable` as `String` or `Int`. Must be `CaseIterable`
    ///
    /// - Parameter name: The name of the preference
    /// - Parameter enumType: Provide enum type here, e.g. `Weekday.self`.
    /// - Parameter info: Optional additional info like instructions, format etc.
    /// - Parameter userDefaultsKey: The key under which this preference is saved in UserDefaults
    /// - Parameter userDefaults: Optionally define a different suite of UserDefaults (standard by default).
    /// - Parameter onDidSet: Optional execution block once the value is changed.
    public convenience init<T: RawRepresentable & CaseIterable> (
        enumName name: String,
        enumType: T.Type,
        info: String? = "",
        userDefaultsKey: String?,
        userDefaults: UserDefaults = .standard,
        onDidSet: ((T?) -> Void)?
    ) where T.RawValue == Int {
        self.init(
            name: name,
            info: info,
            type: .enumeration(allCases: T.allCases as! [any RawRepresentable]),
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            onDidSet: { onDidSet?($0.flatMap(Int.init).flatMap(T.init(rawValue:))) }
        )
    }

}
