//
//  CrashType.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

// Inspiration link: https://github.com/DebugSwift/DebugSwift

import Foundation

enum CrashType: String, Codable {
    case nsexception
    case signal
}

extension CrashType {

    var fileName: String {
        "\(rawValue)_crashes.json"
    }

}
