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

    // MARK: - Public methods
    
    func configure(with item: PerformanceInfoItem) {
        titleLabel.text = item.title
        valueLabel.text = item.value
    }
}
