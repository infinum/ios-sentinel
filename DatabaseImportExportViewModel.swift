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
    let allowedTypes: [UTType] = [.init(filenameExtension: "zigbee")!, .text, .plainText]

    // MARK: - Private properties

    private let databaseFileManager: DatabaseFileManager
    private let databaseURL: URL

    // MARK: - Init

    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        databaseFileManager = .init(fileManager: .default, databaseURL: databaseURL)
    }
}

extension DatabaseImportExportViewModel {

    func importDatabase(url: URL) {
        try! databaseFileManager.importDatabase(from: url)
    }
}
