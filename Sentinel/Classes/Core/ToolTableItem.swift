//
//  ToolTableItem.swift
//  Sentinel
//
//  Created by Nikola Majcen on 29/09/2020.
//

import UIKit

/// Defines tool item behaviour and appearance.
@objc
public protocol ToolTableItem: NSObjectProtocol {
    
    /// Cell used for the item representation.
    ///
    /// - Parameters:
    ///     - tableView: The table view which from which item is available.
    ///     - indexPath: The index path in the table view from where cell should be fetched.
    @objc(cellFromTableView:atIndexPath:)
    func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    
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
    optional func register(at tableView: UITableView)
    
    /// It is called when the item is selected.
    ///
    /// - Parameter viewController: The view controller from which the item has been selected.
    @objc(didSelectFromViewController:)
    optional func didSelect(from viewController: UIViewController)
}
