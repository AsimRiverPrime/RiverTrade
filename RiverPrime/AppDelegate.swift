//
//  AppDelegate.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//
import UIKit
import Firebase
import GoogleSignIn
import SVProgressHUD
import FirebaseMessaging
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var standard: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        Thread.sleep(forTimeInterval: 1.0)
        
        //MARK: - To make SVProgressHUD position center we need this line.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "1059141438445-iq15u0pnvcob3aid1duckiqa1oc8el92.apps.googleusercontent.com")
        
        // Set the messaging delegate
           Messaging.messaging().delegate = self
           
           // Request notification permissions
           UNUserNotificationCenter.current().delegate = self
           UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
               if let error = error {
                   print("Failed to request authorization: \(error.localizedDescription)")
               }
               print("Permission granted: \(granted)")
           }
          
           application.registerForRemoteNotifications()
        listenForKYCUpdates()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func updateBadgeCount() {
        let unseenCount = NotificationHandler.shared.getUnseenNotificationsCount()

        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = unseenCount
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
                  print("Failed to retrieve FCM token")
                  return
              }
              print("Firebase registration token: \(fcmToken)")
        GlobalVariable.instance.firebaseNotificationToken =  fcmToken
        // Optionally, send the token to your server
               // sendTokenToServer(fcmToken)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        if let token = Messaging.messaging().fcmToken {
            print("Retrieved FCM token: \(token)")
        }
        
    }
    
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Foreground notification received: \(userInfo)")
        // Parse the notification payload
             
        // Extract data from the notification payload
        if let type = userInfo["type"] as? String,
           let newStatus = userInfo["new_status"] as? String,
           let title = userInfo["title"] as? String,
           let message = userInfo["message"] as? String {
            
            let notificationItem = NotificationItem(
                id: UUID().uuidString, // Generate a unique ID
                title: title,
                message: message,
                type: type,
                status: newStatus,
                date: Date(),
                isSeen: false
            )

            // Save the notification
            NotificationHandler.shared.saveKYCUpdateLocally(notification: notificationItem)

            // Update the badge count
            updateBadgeCount()
                    // Optionally update the UI
//                    NotificationCenter.default.post(name: NSNotification.Name("KYCStatusUpdated"), object: nil, userInfo: ["type": type, "status": newStatus])
                }

                // Show the notification in the foreground
//                completionHandler([.banner, .sound])
        
        completionHandler([.alert, .sound, .badge])
    }
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification data didReceive: \(userInfo)")
        // Handle KYC status change here
     
        
        completionHandler()
    }
    
    private func handleKYCStatusChange(_ status: String) {
          // Implement your logic for KYC status change
        if status == "completed" {
                   print("KYC process is complete.")
                   // Navigate to another screen or refresh data
               } else {
                   print("KYC status: \(status)")
               }
      }
    
    func listenForKYCUpdates() {
        let db = Firestore.firestore()
        db.collection("users").document("user_id").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            if let kycStatus = document.get("kycStatus") as? String {
                print("KYC Status updated: \(kycStatus)")
                // Update UI or handle status change
//                NotificationCenter.default.post(name: .kycStatusChanged, object: nil, userInfo: ["status": kycStatus])

            }
        }
    }
}
