//
//  NotificationHandler.swift
//  RiverPrime
//
//  Created by Ross Rostane on 15/01/2025.
//

import Foundation

class NotificationHandler {
    static var shared = NotificationHandler()
    
    func saveKYCUpdateLocally(notification: NotificationItem) {
        let userDefaults = UserDefaults.standard
        var notifications = getSavedNotifications()

        // Add the new notification to the list
        notifications.append(notification)

        // Save back to UserDefaults
        if let encodedData = try? JSONEncoder().encode(notifications) {
            userDefaults.set(encodedData, forKey: "notifications")
            userDefaults.synchronize()
        }
    }

    func getSavedNotifications() -> [NotificationItem] {
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.data(forKey: "notifications"),
           let notifications = try? JSONDecoder().decode([NotificationItem].self, from: data) {
            print("\n new notification data saved to userDefaults: \(notifications)")
            return notifications
        }
        return []
    }

    func markNotificationAsSeen(notificationID: String) {
        var notifications = getSavedNotifications()

        // Update the specific notification
        if let index = notifications.firstIndex(where: { $0.id == notificationID }) {
            notifications[index].isSeen = true
        }

        // Save the updated list
        if let encodedData = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encodedData, forKey: "notifications")
            UserDefaults.standard.synchronize()
        }
    }

    func getUnseenNotificationsCount() -> Int {
        return getSavedNotifications().filter { !$0.isSeen }.count
    }
    
}

struct NotificationItem: Codable {
    let id: String
    let title: String
    let message: String
    let type: String
    let status: String
    let date: Date
    var isSeen: Bool
}
