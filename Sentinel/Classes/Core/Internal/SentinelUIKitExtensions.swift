//
//  SentinelUIKitExtensions.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

extension Bundle {
    static var sentinel: Bundle {
        #if SWIFT_PACKAGE
        .module
        #else
        Bundle(for: Sentinel.self)
        #endif
    }
}

extension UIStoryboard {
    static var sentinel: UIStoryboard { UIStoryboard(name: "Sentinel", bundle: .sentinel) }
    
    func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T {
        instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
}

extension UITableView {

    func dequeueReusableCell<T: UITableViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as! T
    }

    func registerNib<T: UITableViewCell>(cellOfType cellType: T.Type) {
        let identifier = String(describing: T.self)
        register(UINib(nibName: identifier, bundle: .sentinel), forCellReuseIdentifier: identifier)
    }
}

