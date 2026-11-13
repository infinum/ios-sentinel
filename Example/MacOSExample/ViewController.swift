//
//  ViewController.swift
//  MacOSExample
//
//  Created by Zvonimir Medak on 20.01.2025..
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet private weak var showSentinelButton: NSButton!

    @IBAction func showSentinel(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("SomeValue"), object: nil)
    }
}

