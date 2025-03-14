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

    private let databaseFilePath: String
    private let allowedTypes: [UTType]

    // MARK: - Lifecycle

    /// - Parameters
    ///   - name: Name of the tool in the Tools section
    ///   - databaseFilePath: Relative path of the database file from the Documents directory
    ///   - allowedTypes: Types of the files which can be imported, should be the type of the database file
    public init(
        name: String = "Database Import/Export Tool",
        databaseFilePath: String,
        allowedTypes: [UTType]
    ) {
        self.name = name
        self.databaseFilePath = databaseFilePath
        self.allowedTypes = allowedTypes
    }
}

// MARK: - UI

public extension DatabaseImportExportTool {

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View {
        DatabaseImportExportView(
            viewModel: DatabaseImportExportViewModel(
                databaseFilePath: databaseFilePath,
                allowedTypes: allowedTypes
            )
        )
    }
    #else
    var content: any View {
        DatabaseImportExportView(
            viewModel: DatabaseImportExportViewModel(
                databaseFilePath: databaseFilePath,
                allowedTypes: allowedTypes
            )
        )
    }
    #endif
}
