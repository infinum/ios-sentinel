//
//  UserDefaultsToolDetailViewModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import Foundation

final class UserDefaultsToolDetailViewModel: ObservableObject {

    // MARK: - Internal properties

    let value: String
    let title: String
    let userDefaults: UserDefaults
    let didDeleteProperty: (() -> Void)?

    // MARK: - Init

    init(value: String, title: String, userDefaults: UserDefaults = .standard, didDeleteProperty: (() -> Void)?) {
        self.value = value
        self.title = title
        self.userDefaults = userDefaults
        self.didDeleteProperty = didDeleteProperty
    }

}

// MARK: - Internal methods

extension UserDefaultsToolDetailViewModel {

    func didPressDelete() {
        userDefaults.removeObject(forKey: title)
        didDeleteProperty?()
    }

}
