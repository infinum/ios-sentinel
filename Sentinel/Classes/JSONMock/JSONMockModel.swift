//
//  JSONMockModel.swift
//  Sentinel
//
//  Created by Maroje Marcelić on 26.05.2023..
//

import Foundation

public class JSONMockModel {
    
    let folders: [JSONMockFolder]
    var usedJSONs: [String: String]
    let jsonsUpdated: ([String: String]) -> Void
    
    public init(
        folders: [JSONMockFolder],
        usedJSONs: [String: String] = [:],
        jsonsUpdated: @escaping ([String: String]) -> Void
    ) {
        self.folders = folders
        self.usedJSONs = usedJSONs
        self.jsonsUpdated = jsonsUpdated
     
        self.usedJSONs = loadFromUserDefaults()
        if usedJSONs.isEmpty {
            updateJSONs()
        }
    }
    
    private func updateJSONs() {
        folders.forEach { folder in
            getUsedJSONns(for: folder)
        }
        jsonsUpdated(usedJSONs)
        saveToUserDefaults()
    }
    
    private func getUsedJSONns(for folder: JSONMockFolder) {
        usedJSONs[folder.folderName] = folder.selectedJSONMock
        
        folder.folders.forEach { folder in
            getUsedJSONns(for: folder)
        }
    }
    
    func triggerJSONUpdates() {
        updateJSONs()
    }
    
    func loadFromUserDefaults() -> [String: String] {
     
        return [:]
    }
    
    func saveToUserDefaults() {
        
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
