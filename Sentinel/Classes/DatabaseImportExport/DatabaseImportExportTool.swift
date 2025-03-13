//
//  DatabaseImportExportTool.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 12.03.2025..
//

import SwiftUI
import UniformTypeIdentifiers

/// Tool which gives the ability to import or export the database file
public struct DatabaseImportExportTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Private properties

    private let databaseFileName: String
    private let allowedTypes: [UTType]

    // MARK: - Lifecycle

    public init(
        name: String = "Database Import/Export Tool",
        databaseFileName: String,
        allowedTypes: [UTType]
    ) {
        self.name = name
        self.databaseFileName = databaseFileName
        self.allowedTypes = allowedTypes
    }
}

// MARK: - UI

public extension DatabaseImportExportTool {

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View {
        DatabaseImportExportView(viewModel: DatabaseImportExportViewModel(databaseURL: databaseURL))
    }
    #else
    var content: any View {
        DatabaseImportExportView(
            viewModel: DatabaseImportExportViewModel(
                databaseFileName: databaseFileName,
                allowedTypes: allowedTypes
            )
        )
    }
    #endif
}
