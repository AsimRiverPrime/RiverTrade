//
//  UserModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/07/2024.
//

import Foundation

struct UserModel {
    var uid: String
    var firstName: String
    var lastName: String
    var phoneNumber: String?
    var email: String
    var password: String
    var emailVerified: Bool
    var phoneNumberVerified: Bool
    var isLogin: Bool
    var pushedToCRM: Bool
    
    // Initializer to create a UserModel from Firestore data
    init(id: String, data: [String: Any]) {
        self.uid = id
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.phoneNumber = data["phoneNumber"] as? String
        self.password = data["password"] as? String ?? ""
        self.emailVerified = data["emailVerified"] as? Bool ?? false
        self.phoneNumberVerified = data["phoneNumberVerified"] as? Bool ?? false
        self.isLogin = data["isLogin"] as? Bool ?? false
        self.pushedToCRM = data["pushedToCRM"] as? Bool ?? false
       
    }
    
    // Function to convert UserModel to a dictionary for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password,
            "emailVerified": emailVerified,
            "phoneNumberVerified": phoneNumberVerified,
            "isLogin": isLogin,
            "pushedToCRM": pushedToCRM
            
            
        ]
        if let phoneNumber = phoneNumber {
            dict["phoneNumber"] = phoneNumber
        }
        return dict
    }
}

