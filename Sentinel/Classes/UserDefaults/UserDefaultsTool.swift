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
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let toolTable = createToolTable(with: userDefaults)
        toolTable.presentPreview(from: viewController)
    }

    public var content: any View {
        SentinelListView(items: createToolTable(with: userDefaults).sections)
    }
}

// MARK: - Internal methods

private extension UserDefaultsTool {
    func createToolTable(with userDefaults: UserDefaults) -> ToolTable {
        let items = userDefaults.dictionaryRepresentation().map { (key, value) in
            ToolTableItem2.navigation(NavigationToolItem(title: "title23", didSelect: { TitleValueView(item: .init(title: "titleee", value: "value"))}))
        }
        .sorted { $0.id < $1.id }

        let section = ToolTableSection(items: items)
        return ToolTable(name: name, sections: [section])
    }
}
