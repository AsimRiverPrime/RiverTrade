//
//  NotificationRouter.swift
//  RiverPrime
//
//  Created by Ross Rostane on 02/06/2025.
//

import Foundation
import UIKit

class NotificationRouter {

    static let shared = NotificationRouter()

    private init() {}

    func route(to type: AppNotificationType, from userInfo: [AnyHashable: Any]) {
        DispatchQueue.main.async {
            guard let topVC = self.topViewController() else {
                print("❌ No top view controller to present from")
                return
            }

            switch type {
            case .shuftiStatusUpdate:
                let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
                if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
                    profileVC.showCloseButton = true
//                    topVC.present(profileVC, animated: true)
                    topVC.navigate(to: profileVC)
                }

            case .deposit, .withdrawal:
                let storyboard = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
                if let notificationVC = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as? NotificationViewController {
                    notificationVC.modalPresentationStyle = .overFullScreen
                    notificationVC.isNotification = true
//                    topVC.present(notificationVC, animated: true)
                    topVC.navigate(to: notificationVC)
                }
                self.refreshList()

            case .unknown:
                print("🚨 Unknown notification type: \(userInfo)")
                let storyboard = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
                if let notificationVC = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as? NotificationViewController {
                    notificationVC.modalPresentationStyle = .overFullScreen
                    notificationVC.isNotification = true
//                    topVC.present(notificationVC, animated: true)
                    topVC.navigate(to: notificationVC)
                }
            }
        }
    }
    
    func refreshList() {
        // Call your API again
         NotificationCenter.default.post(name: NSNotification.Name("didReceivePushNotification"), object: nil)
//        apiClient.getNotifications { [weak self] result in
//            switch result {
//            case .success(let data):
//                self?.notifications = data
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                }
//            case .failure(let error):
//                print("Error fetching notifications: \(error)")
//            }
//        }
    }
    
    private func topViewController(_ base: UIViewController? = {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: \.isKeyWindow) {
            return window.rootViewController
        }
        return nil
    }()) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

enum AppNotificationType: String {
    case shuftiStatusUpdate = "shufti_status_update"
    case deposit
    case withdrawal
    case unknown

    init(from userInfo: [AnyHashable: Any]) {
        if let type = userInfo["type"] as? String {
            self = AppNotificationType(rawValue: type) ?? .unknown
        } else {
            self = .unknown
        }
    }
}
