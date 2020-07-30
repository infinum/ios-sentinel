//
//  Tool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

public protocol Tool {
    var name: String { get }
    func presentPreview(from viewController: UIViewController)
}
