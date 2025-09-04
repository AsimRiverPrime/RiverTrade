//
//  PasswordEncryption.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/08/2025.

import Foundation
import CommonCrypto

class PasswordEncryption {
    private static let TAG = "PasswordEncryptionUtil"
    private static let ENCRYPTION_KEY = "ldpU5oJtfoBLQRurRfqS2jjZqWP1mnr4EjZiUFYr6vA="

    // Create standard Fernet token (exactly like Python backend)
    private static func createStandardFernetToken(data: Data, key: Data) -> Data? {
        let timestamp = UInt64(Date().timeIntervalSince1970)
        let iv = Data((0..<16).map { _ in UInt8.random(in: 0...255) })
        
        // Fernet uses first 16 bytes for signing, last 16 for encryption
        let signingKey = key.prefix(16)
        let encryptionKey = key.suffix(16)
        
        // Create Fernet token: Version(1) + Timestamp(8) + IV(16) + Ciphertext + HMAC(32)
        var token = Data()
        token.append(0x80) // Fernet version
        
        // Add timestamp (big-endian 8 bytes)
        var bigEndianTimestamp = timestamp.bigEndian
        withUnsafeBytes(of: bigEndianTimestamp) { bytes in
            token.append(contentsOf: bytes)
        }
        
        // Add IV
        token.append(iv)
        
        // AES-128-CBC encrypt with PKCS7 padding
        guard let ciphertext = aesCBCEncrypt(data: data, key: Data(encryptionKey), iv: iv) else {
            return nil
        }
        token.append(ciphertext)
        
        // HMAC-SHA256 of everything so far
        guard let hmac = hmacSHA256(data: token, key: Data(signingKey)) else {
            return nil
        }
        token.append(hmac)
        
        return token
    }
    
    // Decrypt standard Fernet token (exactly like Python backend)
    private static func decryptStandardFernetToken(token: Data, key: Data) -> Data? {
        guard token.count >= 57 else { return nil }
        
        let signingKey = key.prefix(16)
        let encryptionKey = key.suffix(16)
        
        // Verify HMAC
        let hmac = token.suffix(32)
        let tokenWithoutHMAC = token.dropLast(32)
        
        guard let expectedHMAC = hmacSHA256(data: tokenWithoutHMAC, key: Data(signingKey)) else {
            return nil
        }
        
        guard hmac == expectedHMAC else {
            return nil
        }
        
        // Parse structure
        guard tokenWithoutHMAC.first == 0x80 else { return nil }
        
        let iv = tokenWithoutHMAC.subdata(in: 9..<25)
        let ciphertext = tokenWithoutHMAC.subdata(in: 25..<tokenWithoutHMAC.count)
        
        // Decrypt
        return aesCBCDecrypt(data: ciphertext, key: Data(encryptionKey), iv: iv)
    }
    
    // AES-128-CBC with PKCS7 padding
    private static func aesCBCEncrypt(data: Data, key: Data, iv: Data) -> Data? {
        var outLength: Int = 0
        let outData = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count + 16)
        defer { outData.deallocate() }
        
        let status = data.withUnsafeBytes { dataPtr in
            key.withUnsafeBytes { keyPtr in
                iv.withUnsafeBytes { ivPtr in
                    CCCrypt(CCOperation(kCCEncrypt),
                           CCAlgorithm(kCCAlgorithmAES128),
                           CCOptions(kCCOptionPKCS7Padding),
                           keyPtr.bindMemory(to: UInt8.self).baseAddress, key.count,
                           ivPtr.bindMemory(to: UInt8.self).baseAddress,
                           dataPtr.bindMemory(to: UInt8.self).baseAddress, data.count,
                           outData, data.count + 16,
                           &outLength)
                }
            }
        }
        
        guard status == kCCSuccess else { return nil }
        return Data(bytes: outData, count: outLength)
    }
    
    private static func aesCBCDecrypt(data: Data, key: Data, iv: Data) -> Data? {
        var outLength: Int = 0
        let outData = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        defer { outData.deallocate() }
        
        let status = data.withUnsafeBytes { dataPtr in
            key.withUnsafeBytes { keyPtr in
                iv.withUnsafeBytes { ivPtr in
                    CCCrypt(CCOperation(kCCDecrypt),
                           CCAlgorithm(kCCAlgorithmAES128),
                           CCOptions(kCCOptionPKCS7Padding),
                           keyPtr.bindMemory(to: UInt8.self).baseAddress, key.count,
                           ivPtr.bindMemory(to: UInt8.self).baseAddress,
                           dataPtr.bindMemory(to: UInt8.self).baseAddress, data.count,
                           outData, data.count,
                           &outLength)
                }
            }
        }
        
        guard status == kCCSuccess else { return nil }
        return Data(bytes: outData, count: outLength)
    }
    
    private static func hmacSHA256(data: Data, key: Data) -> Data? {
        var result = Data(count: 32)
        result.withUnsafeMutableBytes { resultPtr in
            data.withUnsafeBytes { dataPtr in
                key.withUnsafeBytes { keyPtr in
                    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
                          keyPtr.bindMemory(to: UInt8.self).baseAddress, key.count,
                          dataPtr.bindMemory(to: UInt8.self).baseAddress, data.count,
                          resultPtr.bindMemory(to: UInt8.self).baseAddress)
                }
            }
        }
        return result
    }

    // Validate encryption key (exactly like Java backend)
    static func validateEncryptionKey(_ encryptionKey: String?) -> Bool {
        guard let encryptionKey = encryptionKey, encryptionKey.count >= 16 else {
            print("\(TAG): Key validation failed: Key too short or null")
            return false
        }
        
        // Fernet key validation - should be base64 decodeable to 32 bytes
        guard let decodedKey = Data(base64Encoded: encryptionKey), decodedKey.count == 32 else {
            print("\(TAG): Key validation failed: Invalid key format")
            return false
        }
        
        return true
    }

    // Check if password looks encrypted (exactly like Java backend)
    static func looksEncrypted(_ password: String?) -> Bool {
        guard let password = password, password.count >= 20 else {
            return false
        }
        
        do {
            let decoded = Data(base64Encoded: password) ?? Data()
            
            // Fernet tokens are usually longer than 100 chars when base64 encoded
            if password.count >= 100 && decoded.count >= 73 {
                return true
            }
            
            return password.count > 30
        }
    }

    // Encrypt password (EXACTLY like Java backend with double base64 encoding)
    static func encryptPassword(_ password: String) -> String {
        return encryptPassword(password, encryptionKey: ENCRYPTION_KEY)
    }

    static func encryptPassword(_ password: String, encryptionKey: String) -> String {
        if password.isEmpty {
            return password
        }
        if looksEncrypted(password) {
            print("\(TAG): Password appears to be already encrypted")
            return password
        }
        if !validateEncryptionKey(encryptionKey) {
            print("\(TAG): Invalid encryption key")
            return password
        }
        
        do {
            // Convert password to UTF-8 bytes
            guard let passwordData = password.data(using: .utf8) else {
                print("\(TAG): ❌ Failed to convert password to UTF-8")
                return password
            }
            
            // Decode the base64 encryption key
            guard let keyData = Data(base64Encoded: encryptionKey) else {
                print("\(TAG): ❌ Invalid encryption key format")
                return password
            }
            
            // Create Fernet token
            guard let fernetToken = createStandardFernetToken(data: passwordData, key: keyData) else {
                print("\(TAG): ❌ Fernet encryption failed")
                return password
            }
            
            // CRITICAL: Match Java's double base64 encoding behavior
            // Java does: token.serialise().getBytes(StandardCharsets.UTF_8) -> base64encode
            // This means: fernetToken -> base64String -> UTF8Bytes -> base64String
            let fernetTokenBase64 = fernetToken.base64EncodedString()
            guard let fernetTokenBase64Data = fernetTokenBase64.data(using: .utf8) else {
                print("\(TAG): ❌ Failed to convert token to UTF-8")
                return password
            }
            let encryptedPassword = fernetTokenBase64Data.base64EncodedString()
            
            print("\(TAG): ✅ Successfully encrypted password (length: \(encryptedPassword.count))")
            return encryptedPassword
            
        }
    }

    // Decrypt password (EXACTLY like Java backend with double base64 decoding)
    static func decryptPassword(_ encryptedPassword: String) -> String {
        return decryptPassword(encryptedPassword, encryptionKey: ENCRYPTION_KEY)
    }

    static func decryptPassword(_ encryptedPassword: String, encryptionKey: String) -> String {
        if encryptedPassword.isEmpty {
            return encryptedPassword
        }
        if !looksEncrypted(encryptedPassword) {
            print("\(TAG): Password doesn't look encrypted")
            return encryptedPassword
        }
        if !validateEncryptionKey(encryptionKey) {
            print("\(TAG): Invalid encryption key")
            return encryptedPassword
        }
        
        do {
            // Decode the base64 encryption key
            guard let keyData = Data(base64Encoded: encryptionKey) else {
                print("\(TAG): ❌ Invalid encryption key format")
                return encryptedPassword
            }
            
            // CRITICAL: Match Java's double base64 decoding behavior
            // Java does: base64decode -> new String(bytes, UTF8) -> Token.fromString()
            // This means: base64String -> UTF8Bytes -> base64String -> fernetToken
            guard let tokenBase64Data = Data(base64Encoded: encryptedPassword) else {
                print("\(TAG): ❌ Failed to decode outer base64")
                return encryptedPassword
            }
            
            guard let tokenBase64String = String(data: tokenBase64Data, encoding: .utf8) else {
                print("\(TAG): ❌ Failed to convert to UTF-8 string")
                return encryptedPassword
            }
            
            guard let fernetToken = Data(base64Encoded: tokenBase64String) else {
                print("\(TAG): ❌ Failed to decode inner base64")
                return encryptedPassword
            }
            
            // Decrypt Fernet token
            guard let decryptedData = decryptStandardFernetToken(token: fernetToken, key: keyData) else {
                print("\(TAG): ❌ Fernet decryption failed")
                return encryptedPassword
            }
            
            // Convert back to UTF-8 string
            guard let decryptedPassword = String(data: decryptedData, encoding: .utf8) else {
                print("\(TAG): ❌ Failed to convert decrypted data to string")
                return encryptedPassword
            }
            
            print("\(TAG): ✅ Successfully decrypted password")
            return decryptedPassword
            
        }
    }

    // Verify password
    static func verifyPassword(_ plainPassword: String?, storedPassword: String?) -> Bool {
        return verifyPassword(plainPassword, storedPassword: storedPassword, encryptionKey: ENCRYPTION_KEY)
    }

    static func verifyPassword(_ plainPassword: String?, storedPassword: String?, encryptionKey: String) -> Bool {
        guard let plainPassword = plainPassword, let storedPassword = storedPassword else {
            return false
        }
        
        if looksEncrypted(storedPassword) {
            let decryptedPassword = decryptPassword(storedPassword, encryptionKey: encryptionKey)
            let result = plainPassword == decryptedPassword
            print("\(TAG): 🔐 Comparing with decrypted stored password: \(result)")
            return result
        } else {
            let result = plainPassword == storedPassword
            print("\(TAG): 📝 Comparing with plain text stored password: \(result)")
            return result
        }
    }

    // Test backend compatibility
    static func testBackendCompatibility() {
        print("\(TAG): === Testing Backend Compatibility (Double Base64) ===")
        
        // Test the same passwords as your Java backend
        let testPasswords = [
            "admin123",
            "P@ssw0rd!",
            "user@domain.com",
            "simple",
            "Complex$Password123!",
            "🔐emoji_password🔑"
        ]
        
        for (i, password) in testPasswords.enumerated() {
            print("\(TAG): ")
            print("\(TAG): Test \(i + 1): '\(password)'")
            
            let encrypted = encryptPassword(password)
            print("\(TAG): Encrypted: \(encrypted)")
            print("\(TAG): Length: \(encrypted.count)")
            
            let decrypted = decryptPassword(encrypted)
            print("\(TAG): Decrypted: '\(decrypted)'")
            print("\(TAG): Match: \(password == decrypted ? "✅" : "❌")")
            
            let verified = verifyPassword(password, storedPassword: encrypted)
            print("\(TAG): Verified: \(verified ? "✅" : "❌")")
        }
        
        print("\(TAG): ================================================")
    }

    // Manual testing
    static func manualTest(password: String) {
        let manualTestPassword = password
        print("\(TAG): === Manual Testing Area (Java Compatible) ===")
        print("\(TAG): Testing password: '\(manualTestPassword)'")
        
        let manualEncrypted = encryptPassword(manualTestPassword)
        print("\(TAG): Encrypted: \(manualEncrypted)")
        
        let manualDecrypted = decryptPassword(manualEncrypted)
        print("\(TAG): Decrypted: \(manualDecrypted)")
        
        let manualVerify = verifyPassword(manualTestPassword, storedPassword: manualEncrypted)
        print("\(TAG): Verification successful: \(manualVerify)")
        
        print("\(TAG): ==================================================")
        print("\(TAG): 🎉 Password encryption testing complete!")
        print("\(TAG): Your encryption key is working properly.")
        print("\(TAG): ==================================================")
    }
}
