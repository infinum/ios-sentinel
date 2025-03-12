//
//  DatabaseImportExportTool.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 12.03.2025..
//

import SwiftUI

import SwiftUI

/// Tool which gives the ability to import or export the database file
public struct DatabaseImportExportTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Private properties

    private let databaseURL: URL

    // MARK: - Lifecycle

    public init(name: String = "Database Import/Export Tool", databaseURL: URL) {
        self.name = name
        self.databaseURL = databaseURL
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
        DatabaseImportExportView(viewModel: DatabaseImportExportViewModel(databaseURL: databaseURL))
    }
    #endif
}
