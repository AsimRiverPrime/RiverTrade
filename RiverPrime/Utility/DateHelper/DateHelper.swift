//
//  DateHelper.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/12/2024.
//

import Foundation

class DateHelper {
    
    // MARK: - Convert String to Date
//    static func convertToDate(from dateString: String, dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS", timeZone: TimeZone = TimeZone(abbreviation: "UTC")!) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = dateFormat // Default format
//        dateFormatter.timeZone = timeZone     // Default to UTC
//      
//        
//        if let date = dateFormatter.date(from: dateString) {
//            return date
//        }
//        // If that fails, try parsing without milliseconds
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        let datee = dateFormatter.date(from: dateString)
//        return datee
//      
//    }
    static func convertToDate(
        from dateString: String,
        dateFormat: [String] = ["yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd HH:mm:ss"],
        timeZone: TimeZone = TimeZone(abbreviation: "UTC") ?? .current
    ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        
        for format in dateFormat {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }
        
        return nil // If all formats fail
    }

    
    static func timeAgo1(from date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1 // Show only the largest unit (e.g., "2 min")
        formatter.allowedUnits = [.minute, .hour, .day, .weekOfMonth, .month, .year]
        
        let now = Date()
        let elapsed = now.timeIntervalSince(date)
        
        if let formattedString = formatter.string(from: elapsed) {
            return "\(formattedString) ago"
        } else {
            return "Just now"
        }
    }
    
    // MARK: - Time Ago Function
    static func timeAgo(from dateString: String, dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS") -> String {
        // Convert the date string to Date
        guard let apiDate = convertToDate(from: dateString, dateFormat: [dateFormat]) else {
            return "Invalid Date"
        }

        // Use UTC for current date to match API date
        let currentDate = Date()
        let utcCurrentDate = Calendar.current.date(byAdding: .second, value: -TimeZone.current.secondsFromGMT(), to: currentDate)!
        
        // Calculate difference
        let difference = Int(utcCurrentDate.timeIntervalSince(apiDate)) // Total seconds difference
        
        // Calculate time components
        let days = difference / 86400
        let hours = (difference % 86400) / 3600
        let minutes = (difference % 3600) / 60
        
        // Build the output string
        var timeAgoString = ""
        if days > 0 {
            timeAgoString += "\(days) days "
        }
        if hours > 0 {
            timeAgoString += "\(hours) hours "
        }
        if minutes > 0 {
            timeAgoString += "\(minutes) minutes "
        }
        
        return timeAgoString.isEmpty ? "Just now" : "\(timeAgoString)ago"
    }
    
    static func getCurrentWeekDay() -> String {
        // Get the current date
        let currentDate = Date()

        // Create a DateFormatter to format the date as a weekday name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"  // "EEEE" gives full weekday name (e.g., "Monday")

        // Get the weekday name
        let weekdayName = dateFormatter.string(from: currentDate)
        print("weekdayName = \(weekdayName)")
        
        return weekdayName
    }
}
