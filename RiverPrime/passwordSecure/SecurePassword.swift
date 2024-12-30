//
//  SecurePassword.swift
//  RiverPrime
//
//  Created by Ross Rostane on 02/10/2024.
//
import Foundation
import CryptoKit
import Security
//
//class SecurePassword {
//    static var instance = SecurePassword()
//    // Function to save the key in Keychain
//    func saveKeyToKeychain(_ key: SymmetricKey, withIdentifier identifier: String) -> Bool {
//        // Convert the key to data
//        let keyData = key.withUnsafeBytes { Data(Array($0)) }
//
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,            // Store it as a generic password
//            kSecAttrAccount as String: identifier,                    // Use the identifier as the account name
//            kSecValueData as String: keyData,                         // The actual key data
//            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked // Accessibility option
//        ]
//
//        // Remove any existing item with the same identifier
//        SecItemDelete(query as CFDictionary)
//
//        // Add the new key to the Keychain
//        let status = SecItemAdd(query as CFDictionary, nil)
//        return status == errSecSuccess
//    }
//    // Function to retrieve the key from Keychain
//    func retrieveKeyFromKeychain(withIdentifier identifier: String) -> SymmetricKey? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,            // Look for a generic password
//            kSecAttrAccount as String: identifier,                    // Use the identifier to query
//            kSecReturnData as String: kCFBooleanTrue!,                // Request the key data to be returned
//            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
//        ]
//
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
//
//        guard status == errSecSuccess, let keyData = item as? Data else {
//            return nil
//        }
//
//        return SymmetricKey(data: keyData)  // Reconstruct the symmetric key from the retrieved data
//    }
//    
////    if SecurePassword.instance.saveKeyToKeychain(GlobalVariable.instance.passwordKey, withIdentifier: GlobalVariable.instance.keyIdentifier) {
////        print("Key saved successfully.")
////    } else {
////        print("Failed to save the key.")
////    }
////
////    // Retrieving the key from Keychain
////    if let retrievedKey = SecurePassword.instance.retrieveKeyFromKeychain(withIdentifier: GlobalVariable.instance.keyIdentifier) {
////        print("Key retrieved successfully.")
////        
////        // Now you can use this key for encryption or decryption
////    } else {
////        print("Failed to retrieve the key.")
////    }
//}
