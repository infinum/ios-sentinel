//
//  TextEditingViewController.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 31/07/2020.
//

import UIKit

extension UIStoryboard {
    static var textEditing: UIStoryboard { UIStoryboard(name: "TextEditing", bundle: .sentinel) }
}

class TextEditingViewController: UIViewController {

    // MARK: - Private properties
    
    private var name: String!
    private var setter: ((String) -> ())!
    private var getter: (() -> (String))!
   
    // MARK: - IBOutlets
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueTextView: UITextView!
    
    // MARK: - Internal methods
    
    static func create(
        withTitle name: String,
        setter: @escaping (String) -> (),
        getter: @escaping () -> (String)
    ) -> TextEditingViewController {
        let viewController = UIStoryboard.textEditing.instantiateViewController(ofType: TextEditingViewController.self)
        viewController.name = name
        viewController.setter = setter
        viewController.getter = getter
        return viewController
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = name
        valueTextView.text = getter()
    }
    
    // MARK: - IBActions
    
    @IBAction private func didSelectSave() {
        setter(valueTextView.text)
        navigationController?.popViewController(animated: true)
    }
}
