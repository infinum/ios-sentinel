//
//  UserDefaultsToolViewModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import Foundation

final class UserDefaultsToolViewModel: ObservableObject {

    let value: String
    let title: String
    let userDefaults: UserDefaults

    init(value: String, title: String, userDefaults: UserDefaults = .standard) {
        self.value = value
        self.title = title
        self.userDefaults = userDefaults
    }

}

extension UserDefaultsToolViewModel {

    func didPressDelete() {
        UserDefaults.standard.removeObject(forKey: title)
    }

}
