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

    /// Tool's content View
    @ViewBuilder var content: any View { get }
}
