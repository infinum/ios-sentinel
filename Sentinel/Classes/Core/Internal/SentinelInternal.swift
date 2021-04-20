//
//  SentinelInternal.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

extension Sentinel {
    
    /// Presents the Sentinel with tools from provided view controller.
    ///
    /// - Parameters:
    ///     - tools: Tools which will be available in the Sentinel.
    ///     - viewController: The view controller from where will the Sentinel be presented.
    func present(tools: [Tool], on viewController: UIViewController) {
        let items = tools.map { NavigationToolTableItem(title: $0.name, navigate: $0.presentPreview(from:)) }
        let section = ToolTableSection(title: "Tools", items: items)
        let toolTable = ToolTable(name: "Sentinel", sections: [section])
        toolTable.presentPreview(from: viewController, push: false)
    }
}
