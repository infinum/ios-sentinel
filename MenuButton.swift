//
//  MenuButton.swift
//  Sentinel
//
//  Created by Infinum on 12.09.2023..
//

import UIKit

/// A button that opens a context menu with enum cases (raw representables) as options.
class MenuButton: UIButton {

    private var _enumCases: [any RawRepresentable] = []
    private var _handler: ((any RawRepresentable) -> Void)?

    func configure(
        enumCases allCases: [any RawRepresentable],
        handler: ((any RawRepresentable) -> Void)?
    ) {
        self._enumCases = allCases
        self._handler = handler
        configure()
    }

    private func configure() {
        guard #available(iOS 14.0, *) else {
            addTarget(self, action: #selector(configureAlertAsFallbackiOS13AndEarlier), for: .touchUpInside)
            return
        }
        let actions = _enumCases.map { enumCase in
            return UIAction(
                title: enumCase.titleAndRawValue,
                image: nil,
                handler: { [weak self] _ in self?._handler?(enumCase) }
            )
        }
        menu = UIMenu(title: "Select Enum Case", options: [], children: actions)
        showsMenuAsPrimaryAction = true
    }

    func refreshEnumButton(rawValue: String?) {
        if let rawValue, let enumCase = _enumCases.first(where: { String(describing: $0.rawValue) == rawValue }) {
            setTitle(enumCase.titleAndRawValue, for: .normal)
        } else if let rawValue {
            setTitle("Unknown (" + rawValue + ")", for: .normal)
        } else {
            setTitle("Select...", for: .normal)
        }
    }

    // MARK: - Private Methods

    @objc private func configureAlertAsFallbackiOS13AndEarlier() {
        let alert = UIAlertController(title: "Select Enum Case", message: nil, preferredStyle: .alert)
        for enumCase in _enumCases {
            let title = enumCase.rawValue as? String ?? String(describing: enumCase)
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { [weak self] _ in self?._handler?(enumCase) }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        Sentinel.shared.tabBarController?.present(alert, animated: true)
    }
}

extension RawRepresentable {

    var titleAndRawValue: String {
        return String(describing: self) + " (" + rawValueAsString + ")"
    }

    var rawValueAsString: String {
        switch rawValue {
        case let value as Int: return String(value)
        case let value as String: return value
        default: return String(describing: rawValue)
        }
    }
}
