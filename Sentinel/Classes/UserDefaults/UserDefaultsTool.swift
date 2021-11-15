//
//  UserDefaultsTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

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
        let toolTable = createToolTable(with: userDefaults, viewController: viewController)
        toolTable.presentPreview(from: viewController)
    }
}

// MARK: - Internal methods

private extension UserDefaultsTool {
    func createToolTable(with userDefaults: UserDefaults, viewController: UIViewController) -> ToolTable {
        let items = userDefaults.dictionaryRepresentation().map { (key, value) in
            NavigationToolTableItem(title: key) { (viewControoler) in
                let userDefaultsViewController = UserDefaultsViewController.create(
                    withTitle: key,
                    details: String(describing: value)
                )
                viewController.navigationController?.pushViewController(userDefaultsViewController, animated: true)
            }
        }
        let section = ToolTableSection(items: items)
        return ToolTable(name: name, sections: [section])
    }
}
