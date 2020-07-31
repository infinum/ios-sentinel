//
//  AnalyticsCollectorTool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 31/07/2020.
//

import UIKit
import AnalyticsCollector

public class AnalyticsCollectorTool: Tool {
    public var name: String { "Analytics Collector" }
    
    public func presentPreview(from viewController: UIViewController) {
        AnalyticsCollectionManager.shared.showLogs(from: viewController)
    }
}
