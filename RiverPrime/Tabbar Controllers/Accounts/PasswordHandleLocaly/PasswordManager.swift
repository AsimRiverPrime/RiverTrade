//
//  PasswordSave.swift
//  RiverPrime
//
//  Created by Ross Rostane on 31/12/2024.
//

import Foundation
class PasswordManager {
    // Key for UserDefaults storage
    private let userDefaultsKey = "userPasswordData"
    
    // Save a new password
    func savePassword(for id: String, password: String) -> Bool {
        // Retrieve existing passwords
        var savedPasswords = getAllPasswords()
        
        // Check if the ID already exists
        if savedPasswords[id] != nil {
            print("Password for ID \(id) already exists.")
            return false
        }

        savedPasswords[id] = [id: password]
        saveToUserDefaults(savedPasswords)
        print("Password saved for ID \(id).")
        return true
    }
    
    // Retrieve a password for a specific ID
    func getPassword(for id: String) -> String? {
        let savedPasswords = getAllPasswords()
        return savedPasswords[id]?[id]
    }
    
    // Check if an ID exists
    func idExists(_ id: String) -> Bool {
        let savedPasswords = getAllPasswords()
        return savedPasswords[id] != nil
    }
    
    // Retrieve all saved passwords
    func getAllPasswords() -> [String: [String: String]] {
        return UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: [String: String]] ?? [:]
    }
    
    // Private helper to save the updated dictionary to UserDefaults
    private func saveToUserDefaults(_ passwords: [String: [String: String]]) {
        UserDefaults.standard.set(passwords, forKey: userDefaultsKey)
    }
    
    func generateRandomPassword(length: Int) -> String {
        guard length >= 8 else {
            fatalError("Password length must be at least 8 characters.")
        }

        let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz"
        let uppercaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let symbols = "!@#$%^&*()"
        let allCharacters = lowercaseLetters + uppercaseLetters + numbers + symbols

        // Ensure at least one of each required character type
        let randomLowercase = lowercaseLetters.randomElement()!
        let randomUppercase = uppercaseLetters.randomElement()!
        let randomNumber = numbers.randomElement()!
        let randomSymbol = symbols.randomElement()!

        // Fill the rest of the password length with random characters
        let remainingCharacters = (0..<(length - 4)).compactMap { _ in allCharacters.randomElement() }

        // Combine all characters and shuffle them
        let passwordArray = [randomLowercase, randomUppercase, randomNumber, randomSymbol] + remainingCharacters
        return String(passwordArray.shuffled())
    }
    
}
