//
//  UserAccountManager.swift
//  RiverPrime
//
//  Created by Ross Rostane on 27/12/2024.
//

import Foundation
import UIKit

class UserAccountManager {
    static let shared = UserAccountManager()
    let passwordManager = PasswordManager()
    
    private var accounts: [String: UserAccount] = [:]
    private let defaultUserAccountKey = "defaultUserAccount"

    // Update accounts from Firebase response
    func updateAccounts(from firebaseResponse: [String: [String: Any]]) {
//        print("Firebase Response: \(firebaseResponse)\n")
        var updatedAccounts: [String: UserAccount] = [:]

        for (key, value) in firebaseResponse {
            print("Processing account key: \(key)")
            if let account = UserAccount(dictionary: value) {
                updatedAccounts[key] = account
                
                if passwordManager.savePassword(for: String(account.accountNumber), password: account.password) {
                    print("Password saved for account \(account.accountNumber)\n")
                } else {
                    print("Password already exists for account \(account.accountNumber)\n")
                }
            } else {
                print("Could not parse account for key \(key): \(value)")
            }
        }
   
        self.accounts = updatedAccounts
        saveDefaultAccount()
    }

    // Save the default account to UserDefaults
    private func saveDefaultAccount() {
        if let defaultAccount = accounts.values.first(where: { $0.isDefault }) {
            let data = try? JSONEncoder().encode(defaultAccount)
            UserDefaults.standard.set(data, forKey: defaultUserAccountKey)
        }
    }

    // Retrieve the default account
    func getDefaultAccount() -> UserAccount? {
        guard
            let data = UserDefaults.standard.data(forKey: defaultUserAccountKey),
            let account = try? JSONDecoder().decode(UserAccount.self, from: data)
        else {
            return nil
        }

        return account
    }
}


struct UserAccount: Codable {
    let accountNumber: Int
    let isDefault: Bool
    let groupName: String
    let name: String
    let groupID: String
    let userID: String
    let currency: String?
    let kycStatus: String?
    let password: String
    let isReal: Bool

    init?(dictionary: [String: Any]) {
        guard
            let accountNumber = dictionary["accountNumber"] as? Int,
            let isDefault = dictionary["isDefault"] as? Int,
            let groupName = dictionary["groupName"] as? String,
            let name = dictionary["name"] as? String,
            let groupID = dictionary["groupID"] as? String,
            let userID = dictionary["userID"] as? String,
           
            let password = dictionary["password"] as? String,
            let isReal = dictionary["isReal"] as? Int
        else {
            print("❌ Failed to parse UserAccount from: \(dictionary)")
            return nil
        }

        self.accountNumber = accountNumber
        self.isDefault = isDefault == 1
        self.groupName = groupName
        self.name = name
        self.groupID = groupID
        self.userID = userID
       
        self.password = password
        self.isReal = isReal == 1

        // Handle optional field
        self.kycStatus = dictionary["kycStatus"] as? String
        self.currency = dictionary["currency"] as? String
    }
}
