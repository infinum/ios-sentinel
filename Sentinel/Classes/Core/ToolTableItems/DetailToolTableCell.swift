//
//  DetailToolTableCell.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objcMembers
public class DetailToolTableItem: NSObject {
    
    // MARK: - Internal properties
    
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

extension DetailToolTableItem: ToolTableItem {
    
    public func register(at tableView: UITableView) {
        tableView.registerNib(cellOfType: DetailToolTableCell.self)
    }
    
    public func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: DetailToolTableCell.self, for: indexPath)
        cell.configure(with: self)
        return cell
    }
}

class DetailToolTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    // MARK: - Internal methods
    
    func configure(with item: DetailToolTableItem) {
        titleLabel?.text = item.title
        valueLabel?.text = item.detail
    }
}
