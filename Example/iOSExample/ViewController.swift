//
//  ViewController.swift
//  Sentinel
//
//  Created by vlaho.poluta@infinum.hr on 07/30/2020.
//  Copyright (c) 2020 vlaho.poluta@infinum.hr. All rights reserved.
//

import UIKit
import SwiftUI
import Sentinel

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addMenuButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Actions

private extension ViewController {

    @objc func didTapMenu() {
        present(UIHostingController(rootView: MenuView()), animated: true)
    }
}

// MARK: - Private methods

private extension ViewController {

    enum MenuButton {
        static let size: CGFloat = 44
        static let margin: CGFloat = 16
    }

    func addMenuButton() {
        let button = UIButton(type: .system)
        // `line.3.horizontal` is iOS 16, this spelling works on the example's iOS 14 target.
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = MenuButton.size / 2
        button.accessibilityLabel = "Menu"
        button.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: MenuButton.size),
            button.heightAnchor.constraint(equalToConstant: MenuButton.size),
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: MenuButton.margin),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -MenuButton.margin)
        ])
    }
}
