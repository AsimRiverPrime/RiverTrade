//
//  FireStoreService.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/07/2024.
//

import Foundation
import FirebaseFirestore

class FirestoreServices: BaseViewController {
    
    var window: UIWindow?
    
    private let db = Firestore.firestore()
    
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
        
         let db = Firestore.firestore()
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
            print("saved User Data: \(data)")
            
            if let emailVerified = data["emailVerified"] as? Bool, !emailVerified {
                // navigateToEmailVerificationScreen()
                print("navigate to user email verification")
            } else if let phoneVerified = data["phoneVerified"] as? Bool, !phoneVerified {
                // navigateToPhoneVerificationScreen()
                print("navigate to user phone verification")
            } else if let demoAccountCreated = data["demoAccountCreated"] as? Bool, !demoAccountCreated {
                // navigateToRealAccountCreationScreen()
                print("navigate to user demo account")
            } else if let profileStep = data["demoAccountCreated"] as? Int {
                // navigateToRealAccountCreationScreen()
                print("check profile step: \(profileStep)")
            } else {
                print("navigate to Login")
                // navigateToMainScreen()
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
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let mainVC = storyboard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
//           window?.rootViewController = mainVC
//           window?.makeKeyAndVisible()
       }

        func navigateToLoginScreen() {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let loginVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
           self.navigationController?.pushViewController(loginVC, animated: true)
          
       }
       
       private func navigateToEmailVerificationScreen() {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let emailVerificationVC = storyboard.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
           emailVerificationVC.isEmailVerification = true
           self.navigationController?.pushViewController(emailVerificationVC, animated: true)
//           window?.rootViewController = emailVerificationVC
//           window?.makeKeyAndVisible()
       }
       
       private func navigateToPhoneVerificationScreen() {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let phoneVerificationVC = storyboard.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
           phoneVerificationVC.isPhoneVerification = true
           self.navigationController?.pushViewController(phoneVerificationVC, animated: true)
//           window?.rootViewController = phoneVerificationVC
//           window?.makeKeyAndVisible()
       }
       
//       private func navigateToRealAccountCreationScreen() {
//           let storyboard = UIStoryboard(name: "Main", bundle: nil)
//           let realAccountCreationVC = storyboard.instantiateViewController(withIdentifier: "RealAccountCreationViewController") as! RealAccountCreationViewController
//           window?.rootViewController = realAccountCreationVC
//           window?.makeKeyAndVisible()
//       }
   
}
