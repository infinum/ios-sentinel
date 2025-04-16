//
//  DatabaseTool.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 12.03.2025..
//

import SwiftUI
import UniformTypeIdentifiers

/// Tool which gives the ability to import or export the database file
public struct DatabaseTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Private properties

    private let databaseFilePath: String
    private let allowedTypes: [UTType]
    private let exportAsArchive: Bool

    // MARK: - Lifecycle

    /// - Parameters
    ///   - name: Name of the tool in the Tools section
    ///   - databaseFilePath: Relative path of the database file from the Documents directory
    ///   - allowedTypes: Types of the files which can be imported, should be the type of the database file
    public init(
        name: String = "Database Tool",
        databaseFilePath: String,
        allowedTypes: [UTType],
        exportAsArchive: Bool
    ) {
        self.name = name
        self.databaseFilePath = databaseFilePath
        self.allowedTypes = allowedTypes
        self.exportAsArchive = exportAsArchive
    }
}

// MARK: - UI

public extension DatabaseTool {

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View {
        DatabaseView(
            viewModel: DatabaseViewModel(
                databaseFilePath: databaseFilePath,
                allowedTypes: allowedTypes,
                exportAsArchive: exportAsArchive
            )
        )
    }
    #else
    var content: any View {
        DatabaseView(
            viewModel: DatabaseViewModel(
                databaseFilePath: databaseFilePath,
                allowedTypes: allowedTypes,
                exportAsArchive: exportAsArchive
            )
        )
    }
    #endif
}
