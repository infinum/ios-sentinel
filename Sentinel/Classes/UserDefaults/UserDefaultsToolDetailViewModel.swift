//
//  UserDefaultsToolDetailViewModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import Foundation

final class UserDefaultsToolDetailViewModel: ObservableObject {

    // MARK: - Internal properties

    @Published var value: String
    let title: String
    let userDefaults: UserDefaults
    let didUpdateProperty: (() -> Void)?

    // MARK: - Init

    init(value: String, title: String, userDefaults: UserDefaults = .standard, didUpdateProperty: (() -> Void)?) {
        self.value = value
        self.title = title
        self.userDefaults = userDefaults
        self.didUpdateProperty = didUpdateProperty
    }

}

// MARK: - Internal methods

extension UserDefaultsToolDetailViewModel {

    func didPressDelete() {
        userDefaults.removeObject(forKey: title)
        didUpdateProperty?()
    }

    func didPressSave() {
        let object = userDefaults.object(forKey: title)
        if object is String {
            userDefaults.set(value, forKey: title)
        } else if object is Bool, let newValue = Bool(value) {
            userDefaults.set(newValue, forKey: title)
        } else if object is Data, let newValue = Data(base64Encoded: value) {
            userDefaults.set(newValue, forKey: title)
        } else if object is Double, let newValue = Double(value) {
            userDefaults.set(newValue, forKey: title)
        } else if object is Float, let newValue = Float(value) {
            userDefaults.set(newValue, forKey: title)
        } else if object is Int, let newValue = Int(value) {
            userDefaults.set(newValue, forKey: title)
        } else if object is [String] {
            userDefaults.set(value.split(separator: ","), forKey: title)
        }
        didUpdateProperty?()
    }

}
