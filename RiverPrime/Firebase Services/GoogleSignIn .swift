//
//  GoogleSignIn .swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/11/2024.
//

import Foundation
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth
import Firebase
import SVProgressHUD


class GoogleSignIn {
    
    var emailUser: String?
    var odoClientNew = OdooClientNew()
    
    let db = Firestore.firestore()
    let fireBaseService =  FirestoreServices()
    
    
    func authenticateWithFirebase(user: GIDGoogleUser) {
        
        let idToken = user.idToken?.tokenString
        let accessToken = user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken ?? "", accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase authentication failed: \(error.localizedDescription)")
                return
            }
            
            // User is signed in with Firebase successfuly
            if let user = authResult?.user {
                
                UserDefaults.standard.set(user.uid, forKey: "userID")
                self.emailUser = user.email ?? ""
                
                self.db.collection("users").whereField("email", isEqualTo: self.emailUser ?? "").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error checking for existing user: \(error.localizedDescription)")
                    }
                    
                    if let snapshot = querySnapshot, !snapshot.isEmpty {
                        print("User with this email already exists.")
                        self.fireBaseService.fetchUserData(userId: user.uid)
                        
                        let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                            print("Timer fired!")
                            SVProgressHUD.dismiss()
                            self.fireBaseService.handleUserData()
                        }
                        
                    } else {
                        self.odoClientNew.createRecords(firebase_uid: user.uid, email: user.email ?? "", name: user.displayName ?? "")
                        
                        self.fireBaseService.saveAdditionalUserData(userId: user.uid, kyc: false, profileStep: 0, name: user.displayName ?? "No name", userName: user.displayName ?? "", phone: "", email: user.email ?? "", emailVerified: false, phoneVerified: false, loginId: 0, login: false, pushedToCRM: false, demoAccountGroup: "", realAccountCreated: false, demoAccountCreated: false)
                        
                    }
                }
            }
        }
    }
    

}