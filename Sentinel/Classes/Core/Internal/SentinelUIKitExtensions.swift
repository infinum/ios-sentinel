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

#if canImport(UIKit)
import UIKit

extension UIStoryboard {
    static var sentinel: UIStoryboard { UIStoryboard(name: "Sentinel", bundle: .sentinel) }

    func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T {
        instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
}
#endif
