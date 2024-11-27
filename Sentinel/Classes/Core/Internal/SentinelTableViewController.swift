//
//  SentinelTableViewController.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

class SentinelTableViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    private var toolTable: ToolTable!
    
    static func create(with toolTable: ToolTable) -> SentinelTableViewController {
        let viewController = UIStoryboard.sentinel.instantiateViewController(ofType: Self.self)
        viewController.toolTable = toolTable
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()   
        title = toolTable.name
//        toolTable.sections
//            .flatMap { $0.items }
//            .forEach { $0.register?(at: tableView) }
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            navigationItem.rightBarButtonItems = nil
        }
    }
}

extension SentinelTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return toolTable[indexPath].height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return toolTable[indexPath].estimatedHeight ?? 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toolTable[indexPath].didSelect?(from: self)
    }
}

extension SentinelTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        toolTable.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toolTable.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        toolTable[indexPath].cell(from: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        toolTable[section].title
    }
}

extension ToolTable {
    subscript(index: Int) -> ToolTableSection {
        sections[index]
    }
    subscript(indexPath: IndexPath) -> ToolTableItem {
//        sections[indexPath.section].items[indexPath.row]
        PerformanceInfoItem(title: "", valueDidChange: { return "" })
    }
}
