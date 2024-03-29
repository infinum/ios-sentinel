//
//  ToolTable.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

/// Defines tool datasouce which can present different tool sections.
@objcMembers
public class ToolTable: NSObject, Tool {

    // MARK: - Public properties
    
    public let name: String

    // MARK: - Internal properties

    /// Tool sections in the table view.
    let sections: [ToolTableSection]
    
    // MARK: - Lifecycle
    
    /// Creates an instance of the tool table.
    init(name: String, sections: [ToolTableSection]) {
        self.name = name
        self.sections = sections
        super.init()
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        presentPreview(from: viewController, push: true)
    }
    
    @objc(presentPreviewFromViewController:push:)
    public func presentPreview(from viewController: UIViewController, push: Bool) {
        let sentinelController = SentinelTableViewController.create(with: self)
        if let navController = viewController.navigationController, push {
            navController.pushViewController(sentinelController, animated: true)
        } else {
            let navContoller = UINavigationController(rootViewController: sentinelController)
            viewController.present(navContoller, animated: true)
        }
    }
}
