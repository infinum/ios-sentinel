//
//  Tab.swift
//  
//
//  Created by Milos on 24.8.22..
//

import Foundation

enum Tab {
    case device
    case application
    case tools(items: [Tool])
    case preferences(items: [OptionSwitchItem])
    case performance
}
