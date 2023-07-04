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

//    private var inUseJSONList: Set<String>
    
    // MARK: - Lifecycle
    
    public init(
        name: String = "JSON Mock",
        mockModel: JSONMockModel
    ) {
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
        let items = mockModel.folders
            .map { folder in
                NavigationToolTableItem(title: folder.folderName) { [unowned self] viewController in
                    let toolTable = createToolTable(with: folder, viewController: viewController)
                    toolTable.presentPreview(from: viewController, push: true)
                }
            }
        
        let section = ToolTableSection(items: items)
        return ToolTable(name: "Root", sections: [section])
    }
    
    func createToolTable(with mockFolder: JSONMockFolder, viewController: UIViewController) -> ToolTable {
        let items = createItems(from: mockFolder, viewController: viewController)
        
        let section = ToolTableSection(items: items)
        return ToolTable(name: mockFolder.folderName, sections: [section])
    }
    
    func createItems(from mockModel: JSONMockFolder, viewController: UIViewController) -> [NavigationToolTableItem] {
        let onlyJSONItems = mockModel.jsonNames
            .map { json in
                NavigationToolTableItem(title: json, isSelected: mockModel.isSelected(json: json)) { (viewController) in
                    let mockViewController = JSONMockViewController.create(
                        withTitle: json,
                        selectAction: { mockModel.updateSelectedJSONMock(json: json) }
                    )
                    viewController.navigationController?.pushViewController(mockViewController, animated: true)
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
