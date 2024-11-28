//
//  UserDefaultsTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit
import SwiftUI

@objcMembers
public class UserDefaultsTool: NSObject, Tool {
    
    // MARK: - Public properties
    
    public let name: String

    // MARK: - Private properties
    
    private let userDefaults: UserDefaults

    // MARK: - Lifecycle
    
    public init(name: String = "User Defaults Inspector", userDefaults: UserDefaults = .standard) {
        self.name = name
        self.userDefaults = userDefaults
    }

    public var content: any View {
        SentinelListView(title: name, items: createToolTable(with: userDefaults).sections)
    }

}

// MARK: - Internal methods

private extension UserDefaultsTool {
    func createToolTable(with userDefaults: UserDefaults) -> ToolTable {
        let items = userDefaults.dictionaryRepresentation()
            .sorted { $0.key < $1.key }
            .map { (key, value) in
                return ToolTableItem2.navigation(NavigationToolItem(title: key, didSelect: { UserDefaultsToolView(viewModel: .init(value: String(describing: value), title: key, userDefaults: userDefaults)) }))
            }

        let section = ToolTableSection(items: items)
        return ToolTable(name: name, sections: [section])
    }
}
