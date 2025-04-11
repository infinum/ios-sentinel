//
//  Font+Size.swift
//  Pods
//
//  Created by Zvonimir Medak on 17.03.2025..
//

import Foundation
import SwiftUI

enum FontSize: CGFloat {
    case title1 = 24
    case subtitle1 = 16
    case body1 = 13
    case caption1 = 11
}

extension Font {

    static let title1Bold = system(fontSize: .title1, weight: .bold)
    static let subtitle1Bold = system(fontSize: .subtitle1, weight: .bold)
    static let body1Bold = system(fontSize: .body1, weight: .bold)
    static let body1Regular = system(fontSize: .body1, weight: .regular)
    static let caption1Regular = system(fontSize: .caption1, weight: .regular)

    private static func system(fontSize: FontSize, weight: Font.Weight) -> Font {
        system(size: fontSize.rawValue).weight(weight)
    }
}
