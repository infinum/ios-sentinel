//
//  DetailToolTableCell.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

public class DetailToolTableItem: ToolTableItem {
    
    let title: String
    let detail: String

    public init(title: String, detail: String) {
        self.title = title
        self.detail = detail
    }
    
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
    
    func configure(with item: DetailToolTableItem) {
        textLabel?.text = item.title
        detailTextLabel?.text = item.detail
    }
}
