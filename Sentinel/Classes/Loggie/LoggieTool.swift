//
//  LoggieTool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit
import Loggie

public class LoggieTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Internal properties

    private let filter: ((Log) -> Bool)?

    // MARK: - Init

    public init(name: String = "Loggie", filter: ((Log) -> Bool)? = nil) {
        self.name = name
        self.filter = filter
    }

    // MARK: - Tool

    public func presentPreview(from viewController: UIViewController) {
        LoggieManager.shared.showLogs(from: viewController, filter: filter)
    }
}

