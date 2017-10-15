//
//  Date+Concatination.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 7/21/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation

public extension Date {
    
    func sinceToday(_ calendar: Calendar = .current) -> Int {
        let zeroTimeDate = dateWithZeroHourAndMinute(calendar)
        if let zeroTimeDate = zeroTimeDate {
            return Int(self.timeIntervalSince(zeroTimeDate))
        } else {
            assert(false, "Date.sinceToday() internal var zeroTimeDate unexpectedly found nil")
            return 0
        }
    }
    
    func dateWithZeroHourAndMinute(_ calendar: Calendar = .current) -> Date? {
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)
    }
    
    func apply(hours: Int, minutes: Int, calendar: Calendar) -> Date {
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        components.hour = hours
        components.minute = minutes
        return calendar.date(from: components)!
    }
    
    func dateByAppendingSecs(_ secs: Int, calendar: Calendar) -> Date {
        var components   = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.second = 0
        components.second = secs
        return calendar.date(from: components)!
    }
    
    func shortHoursString(_ calendar: Calendar) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = calendar.timeZone
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.dateFormat = "h a"
        return dateFormatter.string(from: self)
    }
    
}

