//
//  ViewController.swift
//  MacOSExample
//
//  Created by Zvonimir Medak on 20.01.2025..
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet private weak var showSentinelButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func showSentinel(_ sender: Any) {
        NotificationCenter.default.post(name: .init("SomeValue"), object: nil)
    }
}

