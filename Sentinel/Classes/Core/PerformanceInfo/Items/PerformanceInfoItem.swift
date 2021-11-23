//
//  PerformanceInfoItem.swift
//  Sentinel
//
//  Created by Nikola Majcen on 18/11/2020.
//

import Foundation

class PerformanceInfoItem: NSObject {

    // MARK: - Internal properties

    let title: String
    let valueDidChange: () -> String

    // MARK: - Lifecycle

    init(title: String, valueDidChange: @escaping () -> String) {
        self.title = title
        self.valueDidChange = valueDidChange
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
