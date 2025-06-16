//
//  DateHelper.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/12/2024.
//

import Foundation

class DateHelper {
    
    // MARK: - Convert String to Date
    static func convertDateToGMT(from time: Double) -> String? {
        
        
        let timestamp: TimeInterval = time // Your API timestamp
        let date = Date(timeIntervalSince1970: timestamp)

        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") // Set timezone to GMT
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd/MM/yy HH:mm:ss" // Customize the date format

        let gmtTime = dateFormatter.string(from: date)
        print("GMT Time: \(gmtTime)")
        return gmtTime
    }
    
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
    
    static func saveAppLaunchDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let today = formatter.string(from: Date())
        UserDefaults.standard.set(today, forKey: "AppLaunchDate")
    }
    
    static func isSameDayAsLastLaunch() -> Bool {
        guard let savedDate = UserDefaults.standard.string(forKey: "AppLaunchDate") else {
            return false // No saved date
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let today = formatter.string(from: Date())
        
        return savedDate == today
    }
}
