//
//  DetailToolTableCell.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objcMembers
public class DetailToolTableItem: NSObject {
    
    // MARK: - Public properties
    
    let title: String
    let detail: String
    
    // MARK: - Lifecycle

    public init(title: String, detail: String) {
        self.title = title
        self.detail = detail
        super.init()
    }
}

// MARK: - ToolTableItem

@objc
extension DetailToolTableItem: ToolTableItem {
    
    public var height: CGFloat {
        return (self as ToolTableItem).height
    }
    
    public var estimatedHeight: CGFloat {
        return (self as ToolTableItem).estimatedHeight
    }
    
    public func register(at tableView: UITableView) {
        tableView.registerNib(cellOfType: DetailToolTableCell.self)
    }
    
    public func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: DetailToolTableCell.self, for: indexPath)
        cell.configure(with: self)
        return cell
    }
    
    public func didSelect(from viewController: UIViewController) { }
}

@objcMembers
class DetailToolTableCell: UITableViewCell {
    
    // MARK: - Public methods
    
    @objc(configureWithItem:)
    func configure(with item: DetailToolTableItem) {
        textLabel?.text = item.title
        detailTextLabel?.text = item.detail
    }
}
