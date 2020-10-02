//
//  OptionSwitchViewController.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

extension UIStoryboard {
    static var optionSwitch: UIStoryboard { UIStoryboard(name: "OptionSwitch", bundle: .toolBox) }
}

class OptionSwitchViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private properties
    
    private var items: [OptionSwitchItem] = []
    
    // MARK: - Public methods
    
    static func create(items: [OptionSwitchItem]) -> OptionSwitchViewController {
        let viewController = UIStoryboard.optionSwitch.instantiateViewController(ofType: OptionSwitchViewController.self)
        viewController.items = items
        return viewController
    }
}

extension OptionSwitchViewController: UITableViewDelegate {
}

extension OptionSwitchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: OptionSwitchTableViewCell.self, for: indexPath)
        cell.delegate = self
        cell.configure(with: items[indexPath.row])
        return cell
    }
}

extension OptionSwitchViewController: OptionSwitchCellDelegate {
    
    func optionSwitch(_ cell: OptionSwitchTableViewCell, didChangeOptionSwitch option: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        items[indexPath.row].change(to: option)
    }
}
