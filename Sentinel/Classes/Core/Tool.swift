//
//  Tool.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import SwiftUI

/// Defines tool behaviour.
public protocol Tool {
    
    /// The name of the tool.
    var name: String { get }

    @ViewBuilder var content: any View { get }
}
