//
//  Date+Concatination.swift
//  Cadence
//
//  Created by Dimitry Panychyk on 7/21/17.
//  Copyright © 2017 Cadence. All rights reserved.
//

import Foundation

public extension Date {
    func dateWithZeroHourAndMinute(_ calendar: Calendar = Calendar.current) -> Date? {
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)
    }
    
    func formattedDataForAPI() -> (NSString) {
        class DateFormatterAPI {
            static var dateFormater: DateFormatter = {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                return formatter
            }()
        }
        return NSString(string: DateFormatterAPI.dateFormater.string(from: self))
    }
    
    func dateInRange(startDate: Date, endDate: Date) -> (Bool) {
        return self.compare(startDate) == .orderedDescending && self.compare(endDate) == .orderedAscending
    }
    
    func dateComponents(_ calendar: Calendar) -> [Calendar.Component : NSNumber] {
        let components   = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        
        let yearNumber   = NSNumber(value: components.year ?? 0)
        let monthNumber  = NSNumber(value: components.month ?? 0)
        let dayNumber    = NSNumber(value: components.day ?? 0)
        let hourNumber   = NSNumber(value: components.hour ?? 0)
        let minuteNumber = NSNumber(value: components.minute ?? 0)
        
        return [.year : yearNumber,
                .month : monthNumber,
                .day : dayNumber,
                .hour : hourNumber,
                .minute : minuteNumber]
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

public extension NSDate {

    @objc public func dateInRange(startDate: NSDate, endDate: NSDate) -> (Bool) {
        return self.compare(startDate as Date) == .orderedDescending && self.compare(endDate as Date) == .orderedAscending
    }
    
    @objc public func formattedDataForAPI() -> (NSString) {
        class DateFormatterAPI {
            static var dateFormater: DateFormatter = {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                return formatter
            }()
        }
        return NSString(string: DateFormatterAPI.dateFormater.string(from: self as Date))
    }
    
    @objc public func dateWithZeroHourAndMinute(_ calendar: Calendar) -> Date? {
        let components = calendar.dateComponents([.year, .month, .day], from: self as Date)

        return calendar.date(from: components)
    }
    
    @objc public func apply(hours: Int, minutes: Int, calendar: Calendar) -> Date {
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self as Date)
        components.hour = hours
        components.minute = minutes
        return calendar.date(from: components)!
    }
    
    @objc public var since1970: TimeInterval {
        return self.timeIntervalSince1970
    }
    
}

