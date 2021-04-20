//
//  UserDefaultsTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

public class UserDefaultsTool: Tool {
    
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
        let toolTable = ToolTable(name: name, sections: [section])
        toolTable.presentPreview(from: viewController)
    }
}
