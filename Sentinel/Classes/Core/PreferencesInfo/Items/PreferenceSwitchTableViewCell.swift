//
//  OptionSwitchTableViewCell.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import UIKit

class PreferenceSwitchTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var optionSwitch: UISwitch!
    
    // MARK: - Private properties
    
    private var optionSwitchActionHandler: ((Bool) -> Void)?
    
    // MARK: - Public methods
    
    func configure(with item: PreferenceSwitchItem) {
        titleLabel.text = item.name
        optionSwitch.isOn = item.getter()
        optionSwitchActionHandler = { item.change(to: $0) }
    }
    
    // MARK: - IBActions
    
    @IBAction func optionSwitchHandler(_ sender: UISwitch) {
        optionSwitchActionHandler?(sender.isOn)
    }
}
