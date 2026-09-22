//
//  SentinelUIKitExtensions.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

extension Bundle {
    static var sentinel: Bundle {
        #if SWIFT_PACKAGE
        .module
        #else
        Bundle(for: Sentinel.self)
        #endif
    }
}
