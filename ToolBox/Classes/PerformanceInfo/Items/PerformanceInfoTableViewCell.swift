//
//  PerformanceInfoTableViewCell.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

class PerformanceInfoTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!

    var item: PerformanceInfoItem?

    // MARK: - Public methods
    
    func configure(with item: PerformanceInfoItem) {
        self.item = item
        titleLabel.text = item.title
        valueLabel.text = item.value
    }

    @objc func update() {
        guard let item = item else { return }
        valueLabel.text = item.value
    }
}
