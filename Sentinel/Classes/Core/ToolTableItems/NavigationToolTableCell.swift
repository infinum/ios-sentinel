//
//  NavigationToolTableCell.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objcMembers
public class NavigationToolTableItem: NSObject {
    
    // MARK: - Internal properties
    
    let title: String
    let navigate: (UIViewController) -> ()

    // MARK: - Lifecycle
    
    public init(title: String, navigate: @escaping (UIViewController) -> ()) {
        self.title = title
        self.navigate = navigate
    }
}

// MARK: - ToolTableItem

extension NavigationToolTableItem: ToolTableItem {

    public func register(at tableView: UITableView) {
        tableView.registerNib(cellOfType: NavigationToolTableCell.self)
    }
    
    public func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: NavigationToolTableCell.self, for: indexPath)
        cell.configure(with: self)
        return cell
    }
    
    public func didSelect(from viewController: UIViewController) {
        navigate(viewController);
    }
}

class NavigationToolTableCell: UITableViewCell {
    
    // MARK: - Internal methods
    
    func configure(with item: NavigationToolTableItem) {
        textLabel?.text = item.title
    }
    
}
