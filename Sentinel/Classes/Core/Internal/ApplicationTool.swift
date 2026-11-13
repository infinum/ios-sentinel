//
//  GeneralInfoTool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation
import SwiftUI

/// Tool which shows Plist information about the App
struct ApplicationTool: Tool {

    // MARK: - Public properties

    public var name: String { tool.name }

    // MARK: - Lifecycle

    init(sections: [CustomInfoTool.Section] = ApplicationInfoProvider.sections) {
        tool = CustomInfoTool(name: "Application", info: sections)
    }

    // MARK: - Private properties

    private let tool: CustomInfoTool
}

// MARK: - Extensions

// MARK: - UI

extension ApplicationTool {

    var toolTable: ToolTable {
        tool.createToolTable(with: tool.info)
    }

    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View {
        SentinelListView(title: name, items: toolTable.sections)
    }
    #else
    var content: any View {
        SentinelListView(title: name, items: toolTable.sections)
    }
    #endif
}
