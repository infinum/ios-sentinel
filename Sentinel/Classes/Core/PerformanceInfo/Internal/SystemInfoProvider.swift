//
//  SystemInfoProvider.swift
//  Sentinel
//
//  Created by Nikola Majcen on 17/11/2020.
//

import Foundation

struct SystemInfoProvider {

    /// Fetches the active time of the app
    var uptime: String {
        secondsToHoursMinutesSeconds(interval: ProcessInfo().systemUptime)
    }
}

private extension SystemInfoProvider {

    func secondsToHoursMinutesSeconds (interval: TimeInterval) -> String {
        let timeInterval = NSInteger(interval)
        let seconds = timeInterval % 60
        let minutes = (timeInterval / 60) % 60
        let hours = (timeInterval / 3600)

        let secondsString = formattedTime(from: seconds)
        let minutesString = formattedTime(from: minutes)
        let hoursString = formattedTime(from: hours)

        return "\(hoursString):\(minutesString):\(secondsString)"
    }

    func formattedTime(from value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }
}
