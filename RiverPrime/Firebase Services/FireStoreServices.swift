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
    
    func fetchUser(withID id: String, completion: @escaping (UserModel?, Error?) -> Void) {
        let userRef = db.collection("users").document(id)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                let user = UserModel(id: document.documentID, data: data)
                completion(user, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
     func fetchUserData(userId: String) {
          let db = Firestore.firestore()
          let docRef = db.collection("users").document(userId)
          
          docRef.getDocument { (document, error) in
              if let document = document, document.exists {
                  if let data = document.data() {
                      self.handleUserData(data: data)
                  }
              } else {
                  print("User document does not exist: \(error?.localizedDescription ?? "Unknown error")")
                  self.navigateToLoginScreen()
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
    
    private func handleUserData(data: [String: Any]) {
           if let emailVerified = data["emailVerified"] as? Bool, !emailVerified {
               navigateToEmailVerificationScreen()
           } else if let phoneVerified = data["phoneVerified"] as? Bool, !phoneVerified {
               navigateToPhoneVerificationScreen()
           } else if let realAccountCreated = data["realAccountCreated"] as? Bool, !realAccountCreated {
//               navigateToRealAccountCreationScreen()
               
           } else {
               navigateToMainScreen()
           }
       }
       
       private func navigateToMainScreen() {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let mainVC = storyboard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
           window?.rootViewController = mainVC
           window?.makeKeyAndVisible()
       }

       private func navigateToLoginScreen() {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let loginVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
//           self.navigationController?.pushViewController(loginVC, animated: true)
           window?.rootViewController = loginVC
           window?.makeKeyAndVisible()
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
