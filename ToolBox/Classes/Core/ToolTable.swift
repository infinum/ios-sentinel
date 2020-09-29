//
//  ToolTable.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

/// Defines tool datasouce which can present different tool sections.
@objcMembers
public class ToolTable: NSObject, Tool {
    
    // MARK: - Public properties
    
    public let name: String
    
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
    func presentPreview(from viewController: UIViewController, push: Bool) {
        let toolBoxController = ToolboxTableViewController.crete(with: self)
        if let navController = viewController.navigationController, push {
            navController.pushViewController(toolBoxController, animated: true)
        } else {
            let navContoller = UINavigationController(rootViewController: toolBoxController)
            viewController.present(navContoller, animated: true)
        }
    }
}

/// Represents tool section in the tool table view.
@objcMembers
public class ToolTableSection: NSObject {
    
    // MARK: - Public properties
    
    /// The title of the section.
    let title: String?
    
    /// Tool items available in the section.
    let items: [ToolTableItem]

    // MARK: - Lifecycle
    
    /// Creates an instance of the section.
    public init(title: String? = nil, items: [ToolTableItem]) {
        self.title = title
        self.items = items
        super.init()
    }
}

/// Defines tool item behaviour and appearance.
@objc
public protocol ToolTableItem: NSObjectProtocol {
    
    /// The height of the item.
    ///
    /// If not defined, a default value is used as `UITableView.automaticDimension`.
    @objc
    optional var height: CGFloat { get }
    
    /// The estimated height of the item.
    ///
    /// If not defined, a default value is used as `44.0`.
    @objc
    optional var estimatedHeight: CGFloat { get }
    
    /// Registers the item to the provided table view.
    ///
    /// - Parameter tableView: The table view which shows the items.
    @objc(registerAtTableView:)
    func register(at tableView: UITableView)
    
    /// Cell used for the item representation.
    ///
    /// - Parameters:
    ///     - tableView: The table view which from which item is available.
    ///     - indexPath: The index path in the table view from where cell should be fetched.
    @objc(cellFromTableView:atIndexPath:)
    func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    
    /// It is called when the item is selected.
    ///
    /// - Parameter viewController: The view controller from which the item has been selected.
    @objc(didSelectFromViewController:)
    func didSelect(from viewController: UIViewController)
}
