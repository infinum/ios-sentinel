//
//  UserDefaultsToolViewModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import Foundation

final class UserDefaultsToolViewModel: ObservableObject {

    // MARK: - Internal properties -

    let value: String
    let title: String
    let userDefaults: UserDefaults

    // MARK: - Init -

    init(value: String, title: String, userDefaults: UserDefaults = .standard) {
        self.value = value
        self.title = title
        self.userDefaults = userDefaults
    }

}

// MARK: - Extensions -

// MARK: - Internal methods

extension UserDefaultsToolViewModel {

    func didPressDelete() {
        UserDefaults.standard.removeObject(forKey: title)
    }

}
