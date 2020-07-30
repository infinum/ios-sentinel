//
//  ToolTable.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

public class ToolTable: Tool {
    
    public let name: String
    let sections: [ToolTableSection]
    
    init(name: String, sections: [ToolTableSection]) {
        self.name = name
        self.sections = sections
    }
    
    public func presentPreview(from viewController: UIViewController) {
        presentPreview(from: viewController, push: true)
    }
    
    func presentPreview(from viewController: UIViewController, push: Bool) {
        let toolBoxController = ToolboxTableViewController.crete(with: self)
        if let navController = viewController.navigationController, push {
            navController.pushViewController(toolBoxController, animated: true)
        } else {
            let navContoller = UINavigationController(rootViewController: toolBoxController)
            viewController.present(navContoller, animated: true)
        }
    }
}

public class ToolTableSection {
    
    let title: String?
    let items: [ToolTableItem]

    public init(title: String? = nil, items: [ToolTableItem]) {
        self.title = title
        self.items = items
    }
}

public protocol ToolTableItem {
    
    var height: CGFloat { get }
    var estimatedHeight: CGFloat { get }
    func register(at tableView: UITableView)
    func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    func didSelect(from viewController: UIViewController)
}

public extension ToolTableItem {
    
    var height: CGFloat { UITableViewAutomaticDimension }
    var estimatedHeight: CGFloat { 44 }
    func register(at tableView: UITableView) {}
    func didSelect(from viewController: UIViewController) {}
}
