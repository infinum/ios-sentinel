//
//  TextEditingViewController.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 31/07/2020.
//

import UIKit

extension UIStoryboard {
    static var textEditing: UIStoryboard { UIStoryboard(name: "TextEditing", bundle: .toolBox) }
}

class TextEditingViewController: UIViewController {

    private var name: String!
    private var setter: ((String) -> ())!
    private var getter: (() -> (String))!
   
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueTextView: UITextView!
    
    static func create(withTitle name: String, setter: @escaping (String) -> (), getter: @escaping () -> (String)) -> TextEditingViewController {
        let viewController = UIStoryboard.textEditing.instantiateViewController(ofType: TextEditingViewController.self)
        viewController.name = name
        viewController.setter = setter
        viewController.getter = getter
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = name
        valueTextView.text = getter()
    }
    
    @IBAction private func didSelectSave() {
        setter(valueTextView.text)
        navigationController?.popViewController(animated: true)
    }

}
