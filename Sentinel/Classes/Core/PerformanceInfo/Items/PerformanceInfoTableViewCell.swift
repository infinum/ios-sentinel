//
//  PerformanceInfoTableViewCell.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

class PerformanceInfoTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!

    // MARK: - Private properties

    private var valueDidChange: (() -> String)?
    private var timer: Timer?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        initializeTimer()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        invalidateTimer()
        initializeTimer()
    }

    // MARK: - Internal methods
    
    func configure(with item: PerformanceInfoItem) {
        self.valueDidChange = item.valueDidChange
        titleLabel.text = item.title
        valueLabel.text = item.valueDidChange()
    }
}

// MARK: - Private methods

private extension PerformanceInfoTableViewCell {

    func initializeTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updatePerformanceInfo),
            userInfo: nil,
            repeats: true
        )
    }

    func invalidateTimer() {
        timer?.invalidate()
    }

    @objc func updatePerformanceInfo() {
        valueLabel.text = valueDidChange?() ?? "--"
    }
}
