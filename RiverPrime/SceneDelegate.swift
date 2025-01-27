//
//  SceneDelegate.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit
import Firebase
import FirebaseFirestoreInternal
import SVProgressHUD

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let fireStoreInstance = FirestoreServices()
    var navigationController : UINavigationController?
    let odoObject = OdooClientNew()
    
    let webSocketManager = WebSocketManager.shared
    
    static var shared: SceneDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? SceneDelegate else {
            assertionFailure("Expected \(SceneDelegate.self) type.")
            return SceneDelegate()
        }
        
        return appDelegate
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        //MARK: - App initialization.
        splash(scene: scene)
//        decideRootViewController()
        
        //MARK: - ProgressBar initialization.
        self.setSVProgressHUD()
        GlobalVariable.instance.socketTimer = 10.0
        
        window!.overrideUserInterfaceStyle = .light
        
        clearData()
        
        odoObject.authenticate()
        
//        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
//            print("\n saved User Data: scenceDelegate \(savedUserData)")
//            if let uid = savedUserData["id"]  as? String {
//                print("UID is: \(uid)")
//                self.fireStoreInstance.fetchUserData(userId: uid)
//            }
//                // Access specific values from the dictionary
//            if let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool {
//
//                    GlobalVariable.instance.isAccountCreated = isCreateDemoAccount
//                }
//
//            fireStoreInstance.handleUserData()
//        }else {
//            fireStoreInstance.navigateToLoginScreen()
//        }

        // Check if the user has authenticated with Face ID
        window?.makeKeyAndVisible()
        
    }
    
    private func clearData() {
        Session.instance.filteredSymbolData?.removeAll()
    }
   
        // Show the main app screen
        func showMainAppScreen() {
//            let mainVC = MainViewController() // Initialize your main ViewController
//            let navigationController = UINavigationController(rootViewController: mainVC)
//            window?.rootViewController = navigationController
        }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
//        navigateToFaceScreen()
        
        //MARK: - //MARK: - Connect web socket.
        self.webSocketManager.connectWebSocket()
        
        if let data = UserDefaults.standard.dictionary(forKey: "userData") {
            print("\n Handle saved User Data for navigation : \(data)")
            
            if let emailVerified = data["emailVerified"] as? Bool, !emailVerified {
                if let email = data["email"] as? String {
//                    odoClientNew.sendOTP(type: "email", email: email , phone: "")
                   
                }
//               navigateToEmailVerificationScreen()
                print("navigate to user email verification")
               
//            } else if let phoneVerified = data["phone"] as? String, phoneVerified == "" {
//               navigateToPhoneVerificationScreen()
//                print("/n navigate to user phone verification")
            } else if let demoAccountCreated = data["demoAccountCreated"] as? Bool, !demoAccountCreated {
//                navigateToDemoAccountCreationScreen()
                print("navigate to user demo account")
//            } else if let profileStep = data["demoAccountCreated"] as? Int {
//                print("check profile step: \(profileStep)")
            } else {
                print("navigate to Main dashboard")
//                navigateToDemoAccountCreationScreen()
                
                NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.FaceAfterLoginConstant.key, dict: [NotificationObserver.Constants.FaceAfterLoginConstant.title: GlobalVariable.instance.controllerName])
                
            }
        }
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        //MARK: - Disconnect web socket.
        self.webSocketManager.DisconnectWebSocket()
        
        UserDefaults.standard.set(true, forKey: "isFaceIDEnabled")
        
    }
    
}

extension SceneDelegate {
    
    private func navigateToFaceScreen() {
//                UserDefaults.standard.set(true, forKey: "isFaceIDEnabled")
        
        if let face = Session.instance.isFaceIDEnabled {
            
            if face {
//                GlobalVariable.instance.isAppBecomeActive = true
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
                
                let navController = UINavigationController(rootViewController: loginVC)
                SCENE_DELEGATE.window?.rootViewController = navController
                SCENE_DELEGATE.window?.makeKeyAndVisible()
            }
        }
        
    }
}

extension SceneDelegate {
    
    func splash(scene: UIScene) {
        
        /// 1. Capture the scene
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        /// 2. Create a new UIWindow using the windowScene constructor which takes in a window scene.
        let window = UIWindow(windowScene: windowScene)
        
        /// 3. Create a view hierarchy programmatically
        let viewController = SplashViewController() //SplashVC()
        let navigation = UINavigationController(rootViewController: viewController)
        
        /// 4. Set the root view controller of the window with your view controller
        window.rootViewController = navigation
        
        /// 5. Set the window and call makeKeyAndVisible()
        self.window = window
        window.makeKeyAndVisible()
        
    }
    
    func decideRootViewController() {
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("\n saved User Data: scenceDelegate \(savedUserData)")
            GlobalVariable.instance.isAppStartAfterLogin = true
            if let uid = savedUserData["id"]  as? String {
                print("UID is:scenceDelegate: \(uid)")
                self.fireStoreInstance.fetchUserData(userId: uid)
                self.fireStoreInstance.fetchUserAccountsData(userId: uid, completion: {
                })
                
            }
            fireStoreInstance.handleUserData()
        }else {
            fireStoreInstance.navigateToLoginScreen()
        }

    }
    
    //MARK: - Activity Indicator
    func setSVProgressHUD() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultAnimationType(.native)
    }
    
}

extension SceneDelegate {
    
    func registerNotifications() {
        
        //Balance Api
        NotificationObserver.shared.registerNotificationObserver(key: NotificationObserver.Constants.MetaTraderLoginConstant.key)
        //Get Balance
        NotificationObserver.shared.registerNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key)
        
    }
    
}
