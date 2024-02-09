//
//  MenuButton.swift
//  Sentinel
//
//  Created by Infinum on 12.09.2023..
//

import UIKit

/// A button that opens a context menu with enum cases (raw representables) as options.
class MenuButton: UIButton {

    private var enumCases: [String] = []
    private var handler: ((String) -> Void)?

    func configure(
        enumCases allCases: [String],
        handler: ((String) -> Void)?
    ) {
        self.enumCases = allCases
        self.handler = handler
        configure()
    }

    private func configure() {
        guard #available(iOS 14.0, *) else {
            addTarget(self, action: #selector(configureAlertAsFallbackiOS13AndEarlier), for: .touchUpInside)
            return
        }
        let actions = enumCases.map { enumCase in
            return UIAction(
                title: enumCase,
                image: nil,
                handler: { [weak self] _ in self?.handler?(enumCase) }
            )
        }
        menu = UIMenu(title: "Select Enum Case", options: [], children: actions)
        showsMenuAsPrimaryAction = true
    }

    func refreshEnumButton(rawValue: String?) {
        if let rawValue, let enumCase = enumCases.first(where: { $0 == rawValue }) {
            setTitle(enumCase, for: .normal)
        } else if let rawValue {
            setTitle("Unknown (" + rawValue + ")", for: .normal)
        } else {
            setTitle("Select...", for: .normal)
        }
    }

    // MARK: - Private Methods

    @objc private func configureAlertAsFallbackiOS13AndEarlier() {
        let alert = UIAlertController(title: "Select Enum Case", message: nil, preferredStyle: .alert)
        for enumCase in enumCases {
            let title = enumCase
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { [weak self] _ in self?.handler?(enumCase) }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        Sentinel.shared.tabBarController?.present(alert, animated: true)
    }
}
