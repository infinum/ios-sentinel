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

    @IBAction func showSentinel(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("SomeValue"), object: nil)
    }
}

