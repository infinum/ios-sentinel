//
//  JSONMockModel.swift
//  Sentinel
//
//  Created by Maroje Marcelić on 26.05.2023..
//

import Foundation

public class JSONMockModel {
    let folders: [JSONMockFolder]
    let jsonsUpdated: ([String: String]) -> Void
    private var usedJSONs: [String: String] = [:]
    
    public init(
        folders: [JSONMockFolder],
        jsonsUpdated: @escaping ([String: String]) -> Void
    ) {
        self.folders = folders
        self.jsonsUpdated = jsonsUpdated
     
        folders.forEach { folder in
            aa(folder: folder)
        }
        
        jsonsUpdated(usedJSONs)
    }
    
    private func aa(folder: JSONMockFolder) {
        usedJSONs[folder.folderName] = folder.selectedJSONMock
        
        folder.folders.forEach { folder in
            aa(folder: folder)
        }
    }
    
}

public class JSONMockFolder {
    
    let jsonNames: [String]
    let folders: [JSONMockFolder]
    let folderName: String
    var selectedJSONMock: String
    
    private init(
        jsonNames: [String] = [],
        folders: [JSONMockFolder] = [],
        folderName: String = "",
        selectedJSONMock: String = ""
    ) {
        self.jsonNames = jsonNames
        self.folders = folders
        self.folderName = folderName
        self.selectedJSONMock = jsonNames.first ?? ""
    }
    
    public convenience init(
        jsonNames: [String] = [],
        folders: [JSONMockFolder] = [],
        folderName: String = ""
    ) {
        self.init(
            jsonNames: jsonNames,
            folders: folders,
            folderName: folderName,
            selectedJSONMock: ""
        )
    }
    
    public func usedJSONs() -> [String] {
        var jsons: [String?] = []

        jsons.append(getFirstJSONFromFolder())
        
        folders.forEach { model in
            let modelJSONS = model.usedJSONs()
            jsons.append(contentsOf: modelJSONS)
        }
        
        return jsons.compactMap { $0 }
    }
    
    func updateSelectedJSONMock(json: String) {
        selectedJSONMock = json
    }
    
    func isSelected(json: String) -> Bool {
        return json == selectedJSONMock
    }
}

private extension JSONMockFolder {
    
    func getFirstJSONFromFolder() -> String? {
        return jsonNames.first
    }

}
