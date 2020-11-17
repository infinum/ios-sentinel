//
//  SystemInfoProvider.swift
//  ToolBox
//
//  Created by Nikola Majcen on 17/11/2020.
//

import Foundation

class SystemInfoProvider {

    var uptime: String {
        secondsToHoursMinutesSeconds(interval: ProcessInfo().systemUptime)
    }
}

private extension SystemInfoProvider {

    func secondsToHoursMinutesSeconds (interval: TimeInterval) -> String {
        let ti = NSInteger(interval)
        let s = ti % 60
        let m = (ti / 60) % 60
        let h = (ti / 3600)
        return "\(h):\(m):\(s)"
    }
}
