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
    let allowedTypes: [UTType]

    // MARK: - Private properties

    private let databaseFileManager: DatabaseFileManager
    let databaseFileName: String

    // MARK: - Init

    init(databaseFileName: String, allowedTypes: [UTType]) {
        self.databaseFileName = databaseFileName
        self.allowedTypes = allowedTypes
        databaseFileManager = .init(databaseFileName: databaseFileName)
    }
}

extension DatabaseImportExportViewModel {

    func importDatabase(url: URL) {
        try? databaseFileManager.importDatabase(from: url)
    }

    func exportDatabase() {
        selectedURL = databaseFileManager.exportDatabase()
    }
}
