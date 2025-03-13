//
//  DatabaseImportExportViewModel.swift
//  Pods
//
//  Created by Zvonimir Medak on 12.03.2025..
//

import SwiftUI
import UniformTypeIdentifiers

final class DatabaseImportExportViewModel: ObservableObject {

    // MARK: - Internal properties

    @Published var selectedURL: URL? = nil
    let allowedTypes: [UTType] = [.init(filenameExtension: "zigbee")!, .text, .plainText, .init(filenameExtension: "realm")!]

    // MARK: - Private properties

    private let databaseFileManager: DatabaseFileManager
    let databaseFileName: String

    // MARK: - Init

    init(databaseFileName: String, fileManager: FileManager) {
        self.databaseFileName = databaseFileName
        databaseFileManager = .init(fileManager: fileManager, databaseFileName: databaseFileName)
    }
}

extension DatabaseImportExportViewModel {

    func importDatabase(url: URL) {
        try! databaseFileManager.importDatabase(from: url)
    }

    func exportDatabase() {
        selectedURL = databaseFileManager.exportDatabase()
    }
}
