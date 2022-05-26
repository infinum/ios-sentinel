//
//  CollarTool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 31/07/2020.
//

import UIKit
import Collar

public class CollarTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Init

    public init(name: String = "Collar") {
        self.name = name
    }

    // MARK: - Tool

    public func presentPreview(from viewController: UIViewController) {
        AnalyticsCollectionManager.shared.showLogs(from: viewController)
    }
}
