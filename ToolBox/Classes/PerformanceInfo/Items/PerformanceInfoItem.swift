//
//  PerformanceInfoItem.swift
//  ToolBox
//
//  Created by Nikola Majcen on 18/11/2020.
//

import Foundation

class PerformanceInfoItem: NSObject {

    // MARK: - Properties

    let title: String
    let value: String

    // MARK: - Lifecycle

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}

// MARK: - ToolTableItem

extension PerformanceInfoItem: ToolTableItem {

    public func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PerformanceInfoTableViewCell.self, for: indexPath)
        cell.configure(with: self)
        return cell
    }

    public func register(at tableView: UITableView) {
        tableView.registerNib(cellOfType: PerformanceInfoTableViewCell.self)
    }
}
