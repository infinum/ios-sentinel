//
//  ToolTable.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objcMembers
public class ToolTable: NSObject, Tool {
    
    // MARK: - Public properties
    
    public let name: String
    let sections: [ToolTableSection]
    
    // MARK: - Lifecycle
    
    init(name: String, sections: [ToolTableSection]) {
        self.name = name
        self.sections = sections
        super.init()
    }
    
    // MARK: - Public methods
    
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

@objcMembers
public class ToolTableSection: NSObject {
    
    // MARK: - Public properties
    
    let title: String?
    let items: [ToolTableItem]

    // MARK: - Lifecycle
    
    public init(title: String? = nil, items: [ToolTableItem]) {
        self.title = title
        self.items = items
        super.init()
    }
}

@objc
public protocol ToolTableItem: NSObjectProtocol {
    
    var height: CGFloat { get }
    var estimatedHeight: CGFloat { get }
    @objc(registerAtTableView:)
    func register(at tableView: UITableView)
    @objc(cellFromTableView:atIndexPath:)
    func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    @objc(didSelectFromViewController:)
    func didSelect(from viewController: UIViewController)
}

public extension ToolTableItem {
    
    var height: CGFloat { UITableView.automaticDimension }
    var estimatedHeight: CGFloat { 44 }
}
