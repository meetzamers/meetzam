//
//  NSDate+Util.swift
//  MySampleApp
//
//  Created by mushroom on 4/14/17.
//
//  eg. set的时候：stringFromDate = Date().iso8601
//      opt: converting back to Date type
//          dateFromString = stringFromDate.dateFromISO8601
//

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
/*
let ISO8601DateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

import Foundation

extension Foundation.Date {
    struct Date {
        static let formatterISO8601: DateFormatter = {
            
            let dateFormatter = DateFormatter()
            
            let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
            dateFormatter.locale = enUSPosixLocale
            dateFormatter.dateFormat = ISO8601DateFormat
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            
            return dateFormatter
        }()
    }
    
    var formattedISO8601: String { return Date.formatterISO8601.string(from: self) }
    
    func formattedISO8601Date(_ iso8601String:String) -> Foundation.Date {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ISO8601DateFormat
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        return  dateFormatter.date(from: iso8601String)!
    }
 
    
    func chatRoomFormatted(_ iso8601String:String) -> String {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ISO8601DateFormat
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        let date = dateFormatter.date(from: iso8601String)
        
        dateFormatter.dateFormat = "dd/MM/yy"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
        
    }
    
    
    func conversationDateFormatted(_ iso8601String:String) -> String {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ISO8601DateFormat
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        let date = dateFormatter.date(from: iso8601String)
        
        dateFormatter.dateFormat = "EEE, MMM dd"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
        
    }
    
    
    func conversationTimeFormatted(_ iso8601String:String) -> String {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ISO8601DateFormat
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        let date = dateFormatter.date(from: iso8601String)
        
        dateFormatter.dateFormat = "MMM dd, hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
        
    }
 
    func TimeFormatted(_ iso8601String:String) -> String {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ISO8601DateFormat
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        let date = dateFormatter.date(from: iso8601String)
        
        dateFormatter.dateFormat = "MMM dd, hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
        
    }

}
*/



