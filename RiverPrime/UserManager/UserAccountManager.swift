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
        var updatedAccounts: [String: UserAccount] = [:]

        for (key, value) in firebaseResponse {
            if let account = UserAccount(dictionary: value) {
                updatedAccounts[key] = account
                
                if passwordManager.savePassword(for: String(account.accountNumber), password: account.password) {
                    print("All Password successfully saved in UserAccountManager Class:")
                } else {
                    print("ID already exists. Cannot save password.")
                }
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
    let currency: String
    let kycStatus: String
    let password: String
    let isReal: Bool

    // Initialize from dictionary
    init?(dictionary: [String: Any]) {
        guard
            let accountNumber = dictionary["accountNumber"] as? Int,
            let isDefault = dictionary["isDefault"] as? Int,
            let groupName = dictionary["groupName"] as? String,
            let name = dictionary["name"] as? String,
            let groupID = dictionary["groupID"] as? String,
            let userID = dictionary["userID"] as? String,
            let currency = dictionary["currency"] as? String,
            let kycStatus = dictionary["KycStatus"] as? String,
            let password = dictionary["password"] as? String,
            let isReal = dictionary["isReal"] as? Int
        else {
            return nil
        }

        self.accountNumber = accountNumber
        self.isDefault = isDefault == 1
        self.groupName = groupName
        self.name = name
        self.groupID = groupID
        self.userID = userID
        self.currency = currency
        self.kycStatus = kycStatus
        self.password = password
        self.isReal = isReal == 1
    }
}
