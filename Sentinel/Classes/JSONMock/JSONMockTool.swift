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
    
    func createToolTable(
        with mockModel: JSONMockModel,
        viewController: UIViewController
    ) -> ToolTable {
        let items = mockModel.folders
            .map { folder in
                NavigationToolTableItem(title: folder.folderName) { [unowned self] viewController in
                    let toolTable = createToolTable(with: folder, model: mockModel, viewController: viewController)
                    toolTable.presentPreview(from: viewController, push: true)
                }
            }
        
        let section = ToolTableSection(items: items)
        return ToolTable(name: "Root", sections: [section])
    }
    
    func createToolTable(
        with mockFolder: JSONMockFolder,
        model: JSONMockModel,
        viewController: UIViewController
    ) -> ToolTable {
        let items = createItems(from: mockFolder, model: model, viewController: viewController)
        
        let section = ToolTableSection(items: items)
        return ToolTable(name: mockFolder.folderName, sections: [section])
    }
    
    func createItems(
        from mockFolder: JSONMockFolder,
        model: JSONMockModel,
        viewController: UIViewController
    ) -> [NavigationToolTableItem] {
        let onlyJSONItems = mockFolder.jsonNames
            .map { json in
                NavigationToolTableItem(
                    title: json,
                    isSelected: mockFolder.isSelected(json: json)) { (viewController) in
                    let mockViewController = JSONMockViewController.create(
                        withTitle: json,
                        selectAction: {
                            mockFolder.updateSelectedJSONMock(json: json)
                            model.triggerJSONUpdates()
                            (viewController as! SentinelTableViewController).c()
                        }
                    )
                    viewController.navigationController?.pushViewController(mockViewController, animated: true)
                }
            }
        
        let folderItems = mockFolder.folders
            .map { folder in
                NavigationToolTableItem(title: folder.folderName) { [unowned self] viewController in
                    let toolTable = createToolTable(with: folder, model: mockModel, viewController: viewController)
                    toolTable.presentPreview(from: viewController, push: true)
                }
            }
        
        return onlyJSONItems + folderItems
        
    }
}
