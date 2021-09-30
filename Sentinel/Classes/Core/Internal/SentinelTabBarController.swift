//
//  SentinelTabBarController.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.09.2021..
//

import Foundation

final class SentinelTabBarController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func close(_ sender: Any) {
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

extension SentinelTabBarController {

    func setupViewControllers(with viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
}
