//
//  DatabaseImportExportViewModel.swift
//  Pods
//
//  Created by Zvonimir Medak on 12.03.2025..
//

import SwiftUI
import UniformTypeIdentifiers

final class DatabaseViewModel: ObservableObject {

    // MARK: - Internal properties

    @Published var selectedURL: URL? = nil
    let allowedTypes: [UTType]

    // MARK: - Private properties

    private let databaseFileManager: DatabaseFileManager
    private let exportAsArchive: Bool

    // MARK: - Init

    init(databaseFilePath: String, allowedTypes: [UTType], exportAsArchive: Bool) {
        self.allowedTypes = allowedTypes
        databaseFileManager = .init(databaseFilePath: databaseFilePath)
        self.exportAsArchive = exportAsArchive
    }
}

extension DatabaseViewModel {

    func importDatabase(url: URL) {
        try? databaseFileManager.importDatabase(from: url)
    }

    func exportDatabase() {
        selectedURL = databaseFileManager.exportDatabase(asArchive: exportAsArchive)
    }
}
