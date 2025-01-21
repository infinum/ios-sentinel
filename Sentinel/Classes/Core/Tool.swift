//
//  Tool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import SwiftUI

/// Defines tool behaviour and the content View.
public protocol Tool {
    
    /// The name of the tool.
    var name: String { get }

    #if os(macOS)
    /// Tool's content View
    func createContent(selection: Binding<String?>) -> any View
    #else
    @ViewBuilder var content: any View { get }
    #endif
}
