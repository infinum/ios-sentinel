//
//  JSONMockViewController.swift
//  
//
//  Created by Maroje Marcelić on 29.03.2023..
//

import UIKit

extension UIStoryboard {
    static var jsonMock: UIStoryboard { UIStoryboard(name: "JSONMock", bundle: .sentinel) }
}

class JSONMockViewController: UIViewController {

    // MARK: - Private properties
    
    private var text: String!
    private var details: String!
    
    // MARK: - IBOutlets
    
    @IBOutlet private var detailsTextView: UITextView!
    
    // MARK: - IBActions

    @objc
    func handleSaveAction() {
        guard let string = detailsTextView.text else { return }
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: title, ofType: "json")!)

        do {
            try string.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
    }
    
    @objc
    func handleUseAction() {
        print("Use pressed")
    }
    
    // MARK: - Internal methods
    
    static func create(withTitle title: String, details: String) -> JSONMockViewController {
        let viewController = UIStoryboard.jsonMock.instantiateViewController(ofType: JSONMockViewController.self)
        viewController.text = title
        var text: String
        if let path = Bundle.main.path(forResource: details, ofType: "json") {
            do {
                text = try String(contentsOfFile: path)
                viewController.details = text
              } catch {
                   // handle error
              }
        }
        return viewController
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = text
        let saveButton = UIBarButtonItem(
            title: "Save", style: .plain,
            target: self,
            action: #selector(self.handleSaveAction)
        )
        let useButton = UIBarButtonItem(
            title: "Use", style: .plain,
            target: self,
            action: #selector(self.handleUseAction)
        )
        self.navigationItem.rightBarButtonItems = [useButton, saveButton]
        detailsTextView.text = details
    }

}
