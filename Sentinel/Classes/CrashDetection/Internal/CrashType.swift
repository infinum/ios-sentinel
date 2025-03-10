//
//  CrashType.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

import Foundation

public enum CrashType: String, Codable {
    case nsexception
    case signal
}

public extension CrashType {

    var fileName: String {
        "\(rawValue)_crashes.json"
    }

}
