//
//  FireStoreService.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/07/2024.
//

import Foundation
import FirebaseFirestore

class FirestoreServices {
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
}
