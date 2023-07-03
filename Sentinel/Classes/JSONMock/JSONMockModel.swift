//
//  JSONMockModel.swift
//  Sentinel
//
//  Created by Maroje Marcelić on 26.05.2023..
//

import Foundation

public struct JSONMockModel {
    let jsonNames: [String]
    let folders: [JSONMockModel]
    let folderName: String
    
    public init(
        jsonNames: [String] = [],
        folders: [JSONMockModel] = [],
        folderName: String = ""
    ) {
        self.jsonNames = jsonNames
        self.folders = folders
        self.folderName = folderName
    }
}
