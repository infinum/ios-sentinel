//
//  JSONMockTool.swift
//  
//
//  Created by Maroje Marcelić on 29.03.2023..
//

import UIKit

@objcMembers
public class JSONMockTool: NSObject, Tool {
    
    // MARK: - Public properties
    
    public let name: String

    // MARK: - Private properties
    
    private let mockModel: JSONMockModel

    // MARK: - Lifecycle
    
    public init(name: String = "JSON Mock", mockModel: JSONMockModel) {
        self.name = name
        self.mockModel = mockModel
    }
    
    // MARK: - Public methods
    
    public func presentPreview(from viewController: UIViewController) {
        let toolTable = createToolTable(with: mockModel, viewController: viewController)
        toolTable.presentPreview(from: viewController)
    }
}

// MARK: - Internal methods

private extension JSONMockTool {
    
    func createToolTable(with mockModel: JSONMockModel, viewController: UIViewController) -> ToolTable {
        let items = createItems(from: mockModel, viewController: viewController)
        
        let section = ToolTableSection(items: items)
        return ToolTable(name: mockModel.folderName, sections: [section])
    }
    
    func createItems(from mockModel: JSONMockModel, viewController: UIViewController) -> [NavigationToolTableItem] {
        let onlyJSONItems = mockModel.jsonNames
            .map { json in
                NavigationToolTableItem(title: json) { (viewControoler) in
                    // Ode ide VC s json textom
                    let vc = JSONMockViewController.create(
                        withTitle: json,
                        details: json
                    )
                    viewController.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        
        let folderItems = mockModel.folders
            .map { folder in
                NavigationToolTableItem(title: folder.folderName) { [unowned self] viewController in
                    let toolTable = createToolTable(with: folder, viewController: viewController)
                    toolTable.presentPreview(from: viewController, push: true)
                }
            }
        
        return onlyJSONItems + folderItems
        
    }
}
