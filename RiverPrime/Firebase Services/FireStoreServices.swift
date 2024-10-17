//
//  FireStoreService.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/07/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


class FirestoreServices: BaseViewController {
    
    var window: UIWindow?
    
    let db = Firestore.firestore()
   
    var odoClientNew = OdooClientNew()
    
    func addUser(_ user: UserModel, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(user.uid)
        userRef.setData(user.toDictionary(), completion: completion)
    }
    
    func addUserAccountData(uid: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
           // Add a new document in collection "userAccount"
           db.collection("userAccount").document(uid).setData(data, merge: true) { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
    }
    
    
//    func fetchUser(withID id: String, completion: @escaping (UserModel?, Error?) -> Void) {
//        let userRef = db.collection("users").document(id)
//        userRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let data = document.data()!
//                let user = UserModel(id: document.documentID, data: data)
//                completion(user, nil)
//            } else {
//                completion(nil, error)
//            }
//        }
//    }
    
    /**
     
     // Retrieve the data from UserDefaults
     if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") as? [String: Any] {
 
         // Access specific values from the dictionary
         if let uid = savedUserData["uid"] as? String,
            let login = savedUserData["login"] as? Int,
            let emailVerified = savedUserData["emailVerified"] as? Int {
 
             // Example condition based on values
             if login == 0 {
                 print("User is not logged in. UID: \(uid)")
             } else {
                 print("User is logged in. UID: \(uid)")
             }
 
             if emailVerified == 0 {
                 print("Email is not verified.")
             }
         }
     }**/
  
       
    func fetchUserData(userId: String) {
        UserDefaults.standard.set(userId, forKey: "userID")
        print("user ID is: \(userId)")
        
//         let db = Firestore.firestore()
         let docRef = db.collection("users").document(userId)
         
         docRef.getDocument { (document, error) in
             if let document = document, document.exists {
                 print("User document exist and data is: \(document) ")
                 if let data = document.data() {
                   
                     print("data is: \(data)")
                     UserDefaults.standard.set(data, forKey: "userData")
                 }
             } else {
                 print("User document does not exist: \(error?.localizedDescription ?? "Unknown error")")

             }
         }
     }
    
    func handleUserData() {
        if let data = UserDefaults.standard.dictionary(forKey: "userData") {
            print("\n Handle saved User Data for navigation : \(data)")
            
            if let emailVerified = data["emailVerified"] as? Bool, !emailVerified {
                if let email = data["email"] as? String {
                    odoClientNew.sendOTP(type: "email", email: email , phone: "")
                   
                }
               navigateToEmailVerificationScreen()
                print("navigate to user email verification")
               
            } else if let phoneVerified = data["phone"] as? String, phoneVerified == "" {
               navigateToPhoneVerificationScreen()
                print("navigate to user phone verification")
            } else if let demoAccountCreated = data["demoAccountCreated"] as? Bool, !demoAccountCreated {
                navigateToDemoAccountCreationScreen()
                print("navigate to user demo account")
//            } else if let profileStep = data["demoAccountCreated"] as? Int {
//                print("check profile step: \(profileStep)")
            } else {
                print("navigate to Main dashboard")
                navigateToDemoAccountCreationScreen()
            }
        }
  }
    
    func checkUserExists(withID id: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document(id)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func updateUserFields(userID: String, fields: [String: Any], completion: @escaping (Error?) -> Void) {
           let userRef = db.collection("users").document(userID)
           userRef.updateData(fields, completion: completion)
       }
    
    //MARK: Get data from the Firebase Firestore by email and UserID
    func getUserDataByEmail(email: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let usersRef = db.collection("users")
        let query = usersRef.whereField("email", isEqualTo: email)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found with this email."])))
                    return
                }
                
                // Assuming email is unique, we take the first document
                let document = documents.first!
                let data = document.data()
                completion(.success(data))
            }
        }
    }
    
    func getUserData(userId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let docRef = db.collection("users").document(userId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document data was empty."])))
                }
            } else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist."])))
            }
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                var users: [[String: Any]] = []
                for document in querySnapshot!.documents {
                    users.append(document.data())
                }
                completion(.success(users))
            }
        }
    }
   
       
       private func navigateToMainScreen() {
           let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
           let mainVC = storyboard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
           self.navigationController?.pushViewController(mainVC, animated: true)
//           window?.rootViewController = mainVC
//           window?.makeKeyAndVisible()
       }

        func navigateToLoginScreen() {
//           let storyboard = UIStoryboard(name: "Main", bundle: nil)
//           let loginVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
//           self.navigationController?.pushViewController(loginVC, animated: true)
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            
            let navController = UINavigationController(rootViewController: loginVC)
            SCENE_DELEGATE.window?.rootViewController = navController
            SCENE_DELEGATE.window?.makeKeyAndVisible()
       }
       
    private func navigateToEmailVerificationScreen() {
               //MARK: - Go to the VerifyCodeViewController Screen.
        let verifyCodeVC = MyNavigationController.shared.getViewController(identifier: .verifyCodeViewController, storyboardType: .main) as? VerifyCodeViewController
        verifyCodeVC!.isEmailVerification = true
       
               let navController = UINavigationController(rootViewController: verifyCodeVC!)
               SCENE_DELEGATE.window?.rootViewController = navController
               SCENE_DELEGATE.window?.makeKeyAndVisible()
           }
       
       private func navigateToPhoneVerificationScreen() {
          
           let phoneVerifyVC = MyNavigationController.shared.getViewController(identifier: .phoneVerifyVC, storyboardType: .main)
           self.ToastMessage("Verify phone number by OTP")
           let navController = UINavigationController(rootViewController: phoneVerifyVC)
           SCENE_DELEGATE.window?.rootViewController = navController
           SCENE_DELEGATE.window?.makeKeyAndVisible()
       }
 
    private func navigateToDemoAccountCreationScreen() {
        
        let dashboardVC = MyNavigationController.shared.getViewController(identifier: .dashboardVC, storyboardType: .dashboard)
        
        let navController = UINavigationController(rootViewController: dashboardVC)
        SCENE_DELEGATE.window?.rootViewController = navController
        SCENE_DELEGATE.window?.makeKeyAndVisible()
        
    }
   
}
