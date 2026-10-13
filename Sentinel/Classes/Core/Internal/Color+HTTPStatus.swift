//
//  Color+HTTPStatus.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI

extension Color {

    /// Green for a successful status, red for a client or server error, grey otherwise.
    static func httpStatus(_ statusCode: Int) -> Color {
        switch statusCode {
        case 200..<300: return .green
        case 400..<600: return .red
        default: return .gray
        }
    }
}
