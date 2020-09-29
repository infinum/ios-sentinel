//
//  NavigationToolTableCell.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objcMembers
public class NavigationToolTableItem: NSObject {
    
    // MARK: - Public properties
    
    let title: String
    let navigate: (UIViewController) -> ()

    // MARK: - Lifecycle
    
    public init(title: String, navigate: @escaping (UIViewController) -> ()) {
        self.title = title
        self.navigate = navigate
        super.init()
    }
}

// MARK: - ToolTableItem

@objc
extension NavigationToolTableItem: ToolTableItem {
    
    public var height: CGFloat {
        return (self as ToolTableItem).height
    }
    
    public var estimatedHeight: CGFloat {
        return (self as ToolTableItem).estimatedHeight
    }
    
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

@objcMembers
class NavigationToolTableCell: UITableViewCell {
    
    // MARK: - Public methods
    
    @objc(configureWithItem:)
    func configure(with item: NavigationToolTableItem) {
        textLabel?.text = item.title
    }
    
}
