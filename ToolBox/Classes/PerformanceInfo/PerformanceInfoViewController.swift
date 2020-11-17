//
//  PerformanceInfoViewController.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit
import QuartzCore

extension UIStoryboard {
    static var performance: UIStoryboard { UIStoryboard(name: "PerformanceInfo", bundle: .toolBox) }
}

enum PerformanceInfoSection: Int, CaseIterable {
    case cpu = 0
    case memory = 1
    case system = 2
}

class PerformanceInfoViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    
    // MARK: - Private properties
    
    private let cpuInfo = CPUInfoProvider()
    private let memoryInfo = MemoryInfoProvider()
    private var timer: Timer?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTimer()
    }
    
    // MARK: - Public methods
    
    static func create() -> PerformanceInfoViewController {
        let viewController = UIStoryboard.performance.instantiateViewController(ofType: PerformanceInfoViewController.self)
        return viewController
    }
    
    func configureTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatePerformanceInfo), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    @objc func updatePerformanceInfo() {
        tableView.reloadData()
    }
}

extension PerformanceInfoViewController: UITableViewDelegate { }

extension PerformanceInfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return PerformanceInfoSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let infoSection = PerformanceInfoSection(rawValue: section) else { return nil }
        switch infoSection {
        case .cpu: return "CPU"
        case .memory: return "Memory"
        case .system: return "System"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let infoSection = PerformanceInfoSection(rawValue: section) else { return 0 }
        switch infoSection {
        case .cpu: return 2
        case .memory: return 1
        case .system: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let infoSection = PerformanceInfoSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch infoSection {
        case .cpu:
            return configureCPUTableCell(for: indexPath, tableView: tableView)
        case .memory:
            return configureMemoryTableCell(for: indexPath, tableView: tableView)
        case .system:
            return configureSystemTableCell(for: indexPath, tableView: tableView)
        }
    }
}

private extension PerformanceInfoViewController {
    
    func configureCPUTableCell(for indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PerformanceInfoTableViewCell.self, for: indexPath)
        if indexPath.row == 0 {
            cell.configure(title: "Current usage", value: String(format: "%.2f%%", cpuInfo.currentUsage))
        } else if indexPath.row == 1 {
            cell.configure(title: "Number of cores", value: String(format: "%d", cpuInfo.numberOfCores))
        }
        return cell
    }
    
    func configureMemoryTableCell(for indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PerformanceInfoTableViewCell.self, for: indexPath)
        let used = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.used, countStyle: .file)
        let total = ByteCountFormatter.string(fromByteCount: memoryInfo.currentUsage.total, countStyle: .file)
        cell.configure(title: "Current usage", value: "\(used) / \(total)")
        return cell
    }
    
    func configureSystemTableCell(for indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PerformanceInfoTableViewCell.self, for: indexPath)
        let time = secondsToHoursMinutesSeconds(interval: ProcessInfo().systemUptime)
        cell.configure(title: "Uptime", value: time)
        return cell
    }
    
    func secondsToHoursMinutesSeconds (interval: TimeInterval) -> String {
        let ti = NSInteger(interval)
        let s = ti % 60
        let m = (ti / 60) % 60
        let h = (ti / 3600)
        return "\(h):\(m):\(s)"
    }
}
