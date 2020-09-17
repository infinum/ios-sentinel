//
//  Tool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

@objc
public protocol Tool {
    var name: String { get }
    
    @objc(presentPreviewFromViewController:)
    func presentPreview(from viewController: UIViewController)
}
