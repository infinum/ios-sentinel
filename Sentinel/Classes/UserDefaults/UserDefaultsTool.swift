//
//  UserDefaultsTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import SwiftUI

/// Tool which gives the ability to list out all of the UserDefaults properties and delete them
public struct UserDefaultsTool: Tool {

    // MARK: - Public properties
    
    public let name: String

    // MARK: - Private properties
    
    private let userDefaults: UserDefaults

    // MARK: - Lifecycle
    
    public init(name: String = "User Defaults Inspector", userDefaults: UserDefaults = .standard) {
        self.name = name
        self.userDefaults = userDefaults
    }
}

// MARK: - UI

public extension UserDefaultsTool {

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View {
        UserDefaultsToolView(viewModel: .init(name: name, userDefaults: userDefaults))
    }
    #else
    var content: any View {
        UserDefaultsToolView(viewModel: .init(name: name, userDefaults: userDefaults))
    }
    #endif
}
