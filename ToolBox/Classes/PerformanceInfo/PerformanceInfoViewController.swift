//
//  PerformanceInfoViewController.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

extension UIStoryboard {
    static var performance: UIStoryboard { UIStoryboard(name: "PerformanceInfo", bundle: .toolBox) }
}

class PerformanceInfoViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Public methods
    
    static func create() -> PerformanceInfoViewController {
        let viewController = UIStoryboard.performance.instantiateViewController(ofType: PerformanceInfoViewController.self)
        return viewController
    }
}

extension PerformanceInfoViewController: UITableViewDelegate { }

extension PerformanceInfoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PerformanceInfoTableViewCell.self, for: indexPath)
        cell.configure(title: "CPU Usage", value: "15%")
        return cell
    }
}
