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
}

extension SentinelTabBarController {

    func setupViewControllers(with viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
}
