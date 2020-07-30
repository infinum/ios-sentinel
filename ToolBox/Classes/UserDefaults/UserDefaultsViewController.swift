//
//  UserDefaultsViewController.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

extension UIStoryboard {
    static var userDefaults: UIStoryboard { UIStoryboard(name: "UserDefaults", bundle: .toolBox) }
}

class UserDefaultsViewController: UIViewController {

    private var text: String!
    private var details: String!
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailsTextView: UITextView!
    
    static func create(withTitle title: String, details: String) -> UserDefaultsViewController {
        let viewController = UIStoryboard.userDefaults.instantiateViewController(ofType: UserDefaultsViewController.self)
        viewController.text = title
        viewController.details = details
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = text
        detailsTextView.text = details
    }

}
