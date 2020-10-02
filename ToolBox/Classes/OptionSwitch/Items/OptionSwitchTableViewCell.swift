//
//  OptionSwitchTableViewCell.swift
//  ToolBox
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

protocol OptionSwitchCellDelegate: class {
    
    func optionSwitch(_ cell: OptionSwitchTableViewCell, didChangeOptionSwitch option: Bool)
}

class OptionSwitchTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var optionSwitch: UISwitch!
    
    // MARK: - Public properties
    
    weak var delegate: OptionSwitchCellDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    // MARK: - Public methods
    
    func configure(with item: OptionSwitchItem) {
        titleLabel.text = item.name
        optionSwitch.isOn = item.option
    }
    
    // MARK: - IBActions
    
    @IBAction func optionSwitchHandler(_ sender: UISwitch) {
        delegate?.optionSwitch(self, didChangeOptionSwitch: sender.isOn)
    }
}

private extension OptionSwitchTableViewCell {
    
    func resetCell() {
        titleLabel.text = nil
        optionSwitch.isOn = false
    }
}
