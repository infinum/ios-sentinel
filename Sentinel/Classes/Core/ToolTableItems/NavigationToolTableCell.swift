//
//  NavigationToolTableCell.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

@objcMembers
public class NavigationToolTableItem: NSObject {
    
    // MARK: - Internal properties
    
    let title: String
    let isSelected: Bool
    let navigate: (UIViewController) -> ()

    // MARK: - Lifecycle
    
    public init(
        title: String,
        isSelected: Bool = false,
        navigate: @escaping (UIViewController) -> ()
    ) {
        self.title = title
        self.isSelected = isSelected
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
    
    @IBOutlet private weak var checkmarkView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Internal methods
    
    func configure(with item: NavigationToolTableItem) {
        titleLabel.text = item.title
        checkmarkView.isHidden = !item.isSelected
    }
    
}
