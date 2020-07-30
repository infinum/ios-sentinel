//
//  UserDefaultsTool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

public class UserDefaultsTool: Tool {
    
    public let name: String
    private let userDefaults: UserDefaults

    public init(name: String = "User Defaults Inspector", userDefaults: UserDefaults = .standard) {
        self.name = name
        self.userDefaults = userDefaults
    }
    
    public func presentPreview(from viewController: UIViewController) {
        let items = userDefaults.dictionaryRepresentation().map { (key, value) in
            NavigationToolTableItem(title: key) { (viewControoler) in
                let userDefaultsViewController = UserDefaultsViewController.create(withTitle: key, details: String(describing: value))
                viewController.navigationController?.pushViewController(userDefaultsViewController, animated: true)
            }
        }
        let section = ToolTableSection(items: items)
        let toolTable = ToolTable(name: name, sections: [section])
        toolTable.presentPreview(from: viewController)
    }
}
