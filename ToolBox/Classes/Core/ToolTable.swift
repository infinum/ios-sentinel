//
//  ToolTable.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

/// Defines tool datasouce which can present different tool sections.
public class ToolTable: Tool {
    
    public let name: String
    
    /// Tool sections in the table view.
    let sections: [ToolTableSection]
    
    /// Creates an instance of the tool table.
    init(name: String, sections: [ToolTableSection]) {
        self.name = name
        self.sections = sections
    }
    
    public func presentPreview(from viewController: UIViewController) {
        presentPreview(from: viewController, push: true)
    }
    
    func presentPreview(from viewController: UIViewController, push: Bool) {
        let toolBoxController = ToolboxTableViewController.create(with: self)
        if let navController = viewController.navigationController, push {
            navController.pushViewController(toolBoxController, animated: true)
        } else {
            let navContoller = UINavigationController(rootViewController: toolBoxController)
            viewController.present(navContoller, animated: true)
        }
    }
}


/// Represents tool section in the tool table view.
public class ToolTableSection {
    
    /// The title of the section.
    let title: String?
    
    /// Tool items available in the section.
    let items: [ToolTableItem]

    /// Creates an instance of the section.
    public init(title: String? = nil, items: [ToolTableItem]) {
        self.title = title
        self.items = items
    }
}

/// Defiens tool item behaviour and appearance.
public protocol ToolTableItem {
    
    /// The height of the item.
    var height: CGFloat { get }
    
    /// The estimated height of the item.
    var estimatedHeight: CGFloat { get }
    
    /// Registers the item to the provided table view.
    ///
    /// - Parameter tableView: The table view which shows the items.
    func register(at tableView: UITableView)
    
    /// Cell used for the item representation.
    ///
    /// - Parameters:
    ///     - tableView: The table view which from which item is available.
    ///     - indexPath: The index path in the table view from where cell should be fetched.
    func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    
    /// It is called when the item is selected.
    ///
    /// - Parameter viewController: The view controller from which the item has been selected.
    func didSelect(from viewController: UIViewController)
}

public extension ToolTableItem {
    
    var height: CGFloat { UITableView.automaticDimension }
    var estimatedHeight: CGFloat { 44 }
    func register(at tableView: UITableView) {}
    func didSelect(from viewController: UIViewController) {}
}
