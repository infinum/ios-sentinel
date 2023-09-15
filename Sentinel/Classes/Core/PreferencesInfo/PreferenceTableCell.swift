//
//  PreferenceTableCell.swift
//  Sentinel
//
//  Created by Infinum on 04.09.2023..
//

import UIKit

class PreferenceTableCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var _titleLabel: UILabel!
    @IBOutlet var _infoLabel: UILabel!
    @IBOutlet var _switch: UISwitch!
    @IBOutlet var _numberField: UITextField!
    @IBOutlet var _textField: UITextField!
    @IBOutlet var _enumButton: MenuButton!

    private var _item: PreferenceItem?

    override func awakeFromNib() {
        super.awakeFromNib()

        _titleLabel?.text = nil
        _titleLabel.text = nil
        _numberField.delegate = self
        _textField.delegate = self
    }

    func configure(with item: PreferenceItem) {
        _item = item
        _titleLabel.text = item.name
        _infoLabel.text = item.info ?? item.rangeDescription
        _infoLabel.isHidden = item.info == nil

        // Hide all the input views initially:
        [_switch, _numberField, _textField, _enumButton].forEach { $0?.isHidden = true }

        let value = item.value ?? ""
        switch item.type {
        case .bool:
            _switch.isOn = (value as NSString).boolValue
            _switch.isHidden = false
            _switch.addTarget(self, action: #selector(switchDidEndEditing), for: .valueChanged)
        case .integer:
            _numberField.text = value
            _numberField.placeholder = item.rangeDescription
            _numberField.isHidden = false
        case .double:
            _numberField.text = value
            _numberField.placeholder = item.rangeDescription
            _numberField.isHidden = false
        case .text:
            _textField.text = value
            _textField.isHidden = false
        case .enumeration(let allCases):
            _enumButton.configure(enumCases: allCases) { [weak self] in self?.menuButtonDidEndEditing($0) }
            _enumButton.refreshEnumButton(rawValue: value)
            _enumButton.isHidden = false
        }
    }

    private func handle(newValue: String?) {
        guard let item = _item else { return }
        do {
            try item.didChangeInputValue(newValue: newValue)
            self.backgroundColor = nil
            _enumButton.refreshEnumButton(rawValue: newValue)
        } catch {
            self.backgroundColor = .red.withAlphaComponent(0.5)
            UIView.animate(withDuration: 1.0, delay: 0.2, options: [.allowUserInteraction]) {
                self.backgroundColor = nil
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        handle(newValue: textField.text)
    }

    func menuButtonDidEndEditing(_ newValue: any RawRepresentable) {
        handle(newValue: newValue.rawValueAsString)
    }

    @objc
    func switchDidEndEditing(_ aSwitch: UISwitch) {
        handle(newValue: String(aSwitch.isOn))
    }
}
