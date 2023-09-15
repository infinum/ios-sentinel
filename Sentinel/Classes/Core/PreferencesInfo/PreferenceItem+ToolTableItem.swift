//
//  PreferenceItem+TableTool.swift
//  Sentinel
//
//  Created by Infinum on 12.09.2023..
//

import UIKit

extension PreferenceItem: ToolTableItem {

    public func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PreferenceTableCell.self, for: indexPath)
        cell.configure(with: self)
        return cell
    }

    public func register(at tableView: UITableView) {
        tableView.registerNib(cellOfType: PreferenceTableCell.self)
    }

    public var height: CGFloat {
        return UITableView.automaticDimension
    }
}
