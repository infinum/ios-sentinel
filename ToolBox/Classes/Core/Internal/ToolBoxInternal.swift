//
//  ToolBox.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

extension ToolBox {
    
    /// Presents the toolbox with tools from provided view controller.
    ///
    /// - Parameters:
    ///     - tools: Tools which will be available in the toolbox.
    ///     - viewController: The view controller from where will the toolbox be presented.
    func present(tools: [Tool], on viewController: UIViewController) {
        let items = tools.map { NavigationToolTableItem(title: $0.name, navigate: $0.presentPreview(from:)) }
        let section = ToolTableSection(title: "Tools", items: items)
        let toolTable = ToolTable(name: "ToolBox", sections: [section])
        toolTable.presentPreview(from: viewController, push: false)
    }
}
