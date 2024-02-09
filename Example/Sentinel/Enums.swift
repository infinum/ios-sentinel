//
//  Enums.swift
//  Sentinel_Example
//
//  Created by Infinum on 14.09.2023..
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

enum Weekday: String, CaseIterable, Codable {
    case monday = "MON"
    case tuesday = "TUE"
    case wednesday = "WED"
    case thursday = "THU"
    case friday = "FRI"
    case saturday = "SAT"
    case sunday = "SUN"
}

enum Direction: Int, CaseIterable {
    case north = 1
    case west = 2
    case east = 3
    case south = 4
}
