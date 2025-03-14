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

    // MARK: - Init

    init(databaseFilePath: String, allowedTypes: [UTType]) {
        self.allowedTypes = allowedTypes
        databaseFileManager = .init(databaseFilePath: databaseFilePath)
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
