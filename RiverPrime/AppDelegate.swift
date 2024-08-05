//
//  AppDelegate.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//
import UIKit
import Firebase
import GoogleSignIn


@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        Thread.sleep(forTimeInterval: 1.0)
      
        FirebaseApp.configure()
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "1059141438445-iq15u0pnvcob3aid1duckiqa1oc8el92.apps.googleusercontent.com")
//       
//        let fireStoreInstance = FirestoreServices()
//        
//        if let user = Auth.auth().currentUser {
//                   // User is signed in.
////                   navigateToMainScreen()
//            print("user is already register")
//            fireStoreInstance.fetchUserData(userId: user.uid)
//               } else {
//                   // No user is signed in.
////                   navigateToLoginScreen()
//                   print("user is not register")
//               }
//        
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


}

