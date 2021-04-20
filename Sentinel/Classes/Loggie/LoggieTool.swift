//
//  LoggieTool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit
import Loggie

public class LoggieTool: Tool {
    
    private let filter: ((Log) -> Bool)?

    public init(filter: ((Log) -> Bool)? = nil) {
        self.filter = filter
    }
    
    public var name: String { "Loggie" }
    
    public func presentPreview(from viewController: UIViewController) {
        LoggieManager.shared.showLogs(from: viewController, filter: filter)
    }
}

