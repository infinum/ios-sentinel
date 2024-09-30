//
//  UserDefaultsViewController.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

extension UIStoryboard {
    static var userDefaults: UIStoryboard { UIStoryboard(name: "UserDefaults", bundle: .sentinel) }
}

class UserDefaultsViewController: UIViewController {

    // MARK: - Private properties
    
    private var text: String!
    private var details: String!
    
    // MARK: - IBOutlets
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailsTextView: UITextView!
    
    // MARK: - Internal methods
    
    static func create(withTitle title: String, details: String) -> UserDefaultsViewController {
        let viewController = UIStoryboard.userDefaults.instantiateViewController(ofType: UserDefaultsViewController.self)
        viewController.text = title
        viewController.details = details
        return viewController
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = text
        detailsTextView.text = details
    }

    // MARK: - Actions

    @IBAction func didSelectDelete(_ sender: Any) {
        guard let key = titleLabel.text else { return }
        UserDefaults.standard.removeObject(forKey: key)
        navigationController?.popViewController(animated: true)
    }
}
