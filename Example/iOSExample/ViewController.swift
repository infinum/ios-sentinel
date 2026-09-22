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
        addStoredDataView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Private methods

private extension ViewController {

    func addStoredDataView() {
        let controller = UIHostingController(rootView: StoredDataView())
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)

        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80),
            controller.view.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            controller.view.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
}
