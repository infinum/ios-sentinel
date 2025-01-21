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
    /// Tool's content View. Selection is a binding provided from the parent view which should be set to nil if we want to navigate the user back to the previous screen.
    func createContent(selection: Binding<String?>) -> any View
    #else
    /// Tool's content View
    @ViewBuilder var content: any View { get }
    #endif
}
