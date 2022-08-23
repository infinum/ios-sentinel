//
//  SentinelTabBarController.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.09.2021..
//

import UIKit

final class SentinelTabBarController: UITabBarController {

    // MARK: - Private properties

    private var didPreselectAction = false
    private var preselectedIndex: Int?

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

       setPreselectedActionIfNeeded()
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

    func setupViewControllers(with viewControllers: [UIViewController], preselectedIndex: Int) {
        self.viewControllers = viewControllers
        self.preselectedIndex = preselectedIndex
    }
}

// MARK: - Private methods -

private extension SentinelTabBarController {

    func setPreselectedActionIfNeeded() {
        defer { didPreselectAction = true }
        guard !didPreselectAction else { return }
        // Preselect Tools tab
        selectedIndex = preselectedIndex ?? 0
    }
}
