//
//  PasswordEncryption.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/08/2025.
//

import Foundation
import CryptoSwift

class PasswordEncryption {
    
    private static let TAG = "PasswordEncryptionUtil"
    private static let ENCRYPTION_KEY = "ldpU5oJtfoBLQRurRfqS2jjZqWP1mnr4EjZiUFYr6vA="
    
    // MARK: - Validate encryption key
    static func validateEncryptionKey(_ encryptionKey: String?) -> Bool {
        guard let key = encryptionKey, key.count >= 16 else {
            print("\(TAG): Key validation failed: Key too short or null")
            return false
        }
        // Base64 decode check
        if Data(base64Encoded: key) == nil {
            print("\(TAG): Key validation failed: Not valid Base64")
            return false
        }
        return true
    }
    
    // MARK: - Check if password looks encrypted
    static func looksEncrypted(_ password: String?) -> Bool {
        guard let password = password, password.count >= 20 else {
            return false
        }
        if let decoded = Data(base64Encoded: password) {
            return password.count >= 100 && decoded.count >= 73
        }
        return password.count > 30
    }
    
    // MARK: - Encrypt password
    static func encryptPassword(_ password: String) -> String {
        return encryptPassword(password, encryptionKey: ENCRYPTION_KEY)
    }
    
    static func encryptPassword(_ password: String, encryptionKey: String) -> String {
        guard !password.isEmpty else { return password }
        
        if looksEncrypted(password) {
            print("\(TAG): Password appears already encrypted")
            return password
        }
        
        guard validateEncryptionKey(encryptionKey),
              let keyData = Data(base64Encoded: encryptionKey) else {
            print("\(TAG): Invalid encryption key")
            return password
        }
        
        do {
            // Fernet token generation simplified
            let iv = AES.randomIV(16)
            let aes = try AES(key: keyData.byteArray, blockMode: CBC(iv: iv), padding: .pkcs7)
            let encrypted = try aes.encrypt(password.bytes)
            let tokenData = Data(iv + encrypted)
            let encryptedString = tokenData.base64EncodedString()
            print("✅ Successfully encrypted password (length: \(encryptedString.count))")
            return encryptedString
        } catch {
            print("❌ Encryption failed: \(error.localizedDescription)")
            return password
        }
    }
    
    // MARK: - Decrypt password
    static func decryptPassword(_ encryptedPassword: String) -> String {
        return decryptPassword(encryptedPassword, encryptionKey: ENCRYPTION_KEY)
    }
    
    static func decryptPassword(_ encryptedPassword: String, encryptionKey: String) -> String {
        guard !encryptedPassword.isEmpty else { return encryptedPassword }
        
        if !looksEncrypted(encryptedPassword) {
            print("\(TAG): Password doesn't look encrypted")
            return encryptedPassword
        }
        
        guard validateEncryptionKey(encryptionKey),
              let keyData = Data(base64Encoded: encryptionKey),
              let tokenData = Data(base64Encoded: encryptedPassword) else {
            print("\(TAG): Invalid encryption key or token")
            return encryptedPassword
        }
        
        do {
            let iv = Array(tokenData[0..<16])
            let cipherBytes = Array(tokenData[16...])
            let aes = try AES(key: keyData.byteArray, blockMode: CBC(iv: iv), padding: .pkcs7)
            let decrypted = try aes.decrypt(cipherBytes)
            if let decryptedString = String(bytes: decrypted, encoding: .utf8) {
                print("✅ Successfully decrypted password")
                return decryptedString
            }
            return encryptedPassword
        } catch {
            print("❌ Decryption failed: \(error.localizedDescription)")
            return encryptedPassword
        }
    }
    
    // MARK: - Verify password
    static func verifyPassword(_ plainPassword: String, storedPassword: String) -> Bool {
        return verifyPassword(plainPassword, storedPassword: storedPassword, encryptionKey: ENCRYPTION_KEY)
    }
    
    static func verifyPassword(_ plainPassword: String, storedPassword: String, encryptionKey: String) -> Bool {
        guard !plainPassword.isEmpty, !storedPassword.isEmpty else { return false }
        
        if looksEncrypted(storedPassword) {
            let decrypted = decryptPassword(storedPassword, encryptionKey: encryptionKey)
            let result = plainPassword == decrypted
            print("🔐 Comparing with decrypted stored password: \(result)")
            return result
        } else {
            let result = plainPassword == storedPassword
            print("📝 Comparing with plain text stored password: \(result)")
            return result
        }
    }
    
    // MARK: - Manual test
    static func manualTest(_testPassword: String) {
        let testPassword = _testPassword
        print("=== Manual Testing Area ===")
        print("Testing password: '\(testPassword)'")
        
        let encrypted = encryptPassword(testPassword)
        print("Encrypted: \(encrypted)")
        
        let decrypted = decryptPassword(encrypted)
        print("Decrypted: \(decrypted)")
        
        let verified = verifyPassword(testPassword, storedPassword: encrypted)
        print("Verification successful: \(verified)")
    }
}

//final class PasswordEncryption1 {
//
//    private static let TAG = "PasswordEncryptionUtil"
//    private static let ENCRYPTION_KEY = "ldpU5oJtfoBLQRurRfqS2jjZqWP1mnr4EjZiUFYr6vA="
//
//    // ===== Public API (same surface as your Java class) =====
//
//    static func validateEncryptionKey(_ encryptionKey: String?) -> Bool {
//        guard let key = encryptionKey, key.count >= 16 else {
//            print("\(TAG): Key validation failed: Key too short or null")
//            return false
//        }
//        // Accept both Base64URL and normal Base64 with/without padding
//        return decodeBase64Either(key) != nil
//    }
//
//    static func looksEncrypted(_ password: String?) -> Bool {
//        guard let password = password, password.count >= 20 else { return false }
//        // In your Android code the token string (base64url) is THEN Base64-encoded again.
//        // So here we first try to Base64-decode it back to the base64url token string.
//        if let decoded = Data(base64Encoded: password) {
//            // A valid Fernet token string (base64url) is typically ~120+ chars for short inputs.
//            // And its raw bytes (after base64url decode) are: 1 (ver) + 8 (ts) + 16 (IV) + N (ct) + 32 (HMAC) >= 57
//            if let tokenBytes = base64UrlDecode(String(data: decoded, encoding: .utf8) ?? "") {
//                return tokenBytes.count >= 57
//            }
//        }
//        return password.count > 30
//    }
//
//    static func encryptPassword(_ password: String) -> String {
//        encryptPassword(password, encryptionKey: ENCRYPTION_KEY)
//    }
//
//    static func encryptPassword(_ password: String, encryptionKey: String) -> String {
//        guard !password.isEmpty else { return password }
//
//        if looksEncrypted(password) {
//            print("\(TAG): Password appears to be already encrypted")
//            return password
//        }
//        guard let keyBytes = decodeBase64Either(encryptionKey) else {
//            print("\(TAG): Invalid encryption key")
//            return password
//        }
//        guard keyBytes.count == 32 else {
//            print("\(TAG): Fernet key must be 32 bytes (got \(keyBytes.count))")
//            return password
//        }
//
//        do {
//            let nowSeconds = UInt64(Date().timeIntervalSince1970)
//            let iv = AES.randomIV(16)
//            let signingKey = Array(keyBytes[0..<16])
//            let encryptionKey = Array(keyBytes[16..<32])
//
//            // Encrypt (AES-128-CBC, PKCS7)
//            let aes = try AES(key: encryptionKey, blockMode: CBC(iv: iv), padding: .pkcs7)
//            let plaintext = Array(password.utf8)
//            let ciphertext = try aes.encrypt(plaintext)
//
//            // Build token body: version(0x80) || timestamp(8B big-endian) || IV(16B) || ciphertext
//            var tokenBody = [UInt8]()
//            tokenBody.append(0x80)
//            tokenBody += bigEndian8(nowSeconds)
//            tokenBody += iv
//            tokenBody += ciphertext
//
//            // HMAC-SHA256 over tokenBody
//            let hmac = try HMAC(key: signingKey, variant: .sha256).authenticate(tokenBody)
//
//            // token = tokenBody || hmac
//            let tokenBytes = tokenBody + hmac
//
//            // Base64URL(without padding) encode the token to string (Fernet token string)
//            let fernetTokenString = base64UrlEncode(Data(tokenBytes))
//
//            // IMPORTANT: Match your Android code:
//            // Android stores Base64( token.serialise().getBytes(UTF-8) )
//            // So we take the base64url token STRING's UTF-8 bytes, and Base64-encode that.
//            let wrapped = Data(fernetTokenString.utf8).base64EncodedString()
//
//            print("✅ Successfully encrypted password (length: \(wrapped.count))")
//            return wrapped
//        } catch {
//            print("❌ Encryption failed: \(error)")
//            return password
//        }
//    }
//
//    static func decryptPassword(_ encryptedPassword: String) -> String {
//        decryptPassword(encryptedPassword, encryptionKey: ENCRYPTION_KEY)
//    }
//
//    static func decryptPassword(_ encryptedPassword: String, encryptionKey: String,
//                                ttlSeconds: TimeInterval = 365*24*60*60) -> String {
//        guard !encryptedPassword.isEmpty else { return encryptedPassword }
//
//        if !looksEncrypted(encryptedPassword) {
//            print("\(TAG): Password doesn't look encrypted")
//            return encryptedPassword
//        }
//        guard let keyBytes = decodeBase64Either(encryptionKey), keyBytes.count == 32 else {
//            print("\(TAG): Invalid encryption key")
//            return encryptedPassword
//        }
//        guard let tokenStringData = Data(base64Encoded: encryptedPassword),
//              let tokenString = String(data: tokenStringData, encoding: .utf8),
//              let tokenBytes = base64UrlDecode(tokenString) else {
//            print("\(TAG): Invalid wrapped token")
//            return encryptedPassword
//        }
//
//        do {
//            // Split fields: tokenBody || hmac
//            guard tokenBytes.count >= 1 + 8 + 16 + 32 else {
//                throw FernetError.invalidToken
//            }
//            let tokenBody = Array(tokenBytes[0..<(tokenBytes.count - 32)])
//            let macGiven = Array(tokenBytes[(tokenBytes.count - 32)..<tokenBytes.count])
//
//            // Verify version
//            guard tokenBody[0] == 0x80 else { throw FernetError.unsupportedVersion }
//
//            // Parse timestamp (8 bytes big-endian)
//            let tsStart = 1
//            let tsEnd = tsStart + 8
//            let timestampBytes = Array(tokenBody[tsStart..<tsEnd])
//            let ts = toUInt64BE(timestampBytes)
//
//            // TTL check
//            if ttlSeconds > 0 {
//                let now = UInt64(Date().timeIntervalSince1970)
//                if now < ts || now - ts > UInt64(ttlSeconds) {
//                    throw FernetError.tokenExpired
//                }
//            }
//
//            // Compute HMAC over tokenBody and compare
//            let signingKey = Array(keyBytes[0..<16])
//            let macCalc = try HMAC(key: signingKey, variant: .sha256).authenticate(tokenBody)
//            
//            guard constantTimeEqual(macCalc, macGiven) else {
//                throw FernetError.badHMAC
//            }
//            // Extract IV and ciphertext
//            let ivStart = tsEnd
//            let ivEnd = ivStart + 16
//            let iv = Array(tokenBody[ivStart..<ivEnd])
//            let ciphertext = Array(tokenBody[ivEnd..<tokenBody.count])
//
//            // Decrypt
//            let encryptionKey = Array(keyBytes[16..<32])
//            let aes = try AES(key: encryptionKey, blockMode: CBC(iv: iv), padding: .pkcs7)
//            let plaintextBytes = try aes.decrypt(ciphertext)
//
//            guard let plaintext = String(bytes: plaintextBytes, encoding: .utf8) else {
//                throw FernetError.badEncoding
//            }
//            print("✅ Successfully decrypted password")
//            return plaintext
//        } catch {
//            print("❌ Decryption failed: \(error)")
//            return encryptedPassword
//        }
//    }
//
//    static func verifyPassword(_ plainPassword: String, storedPassword: String) -> Bool {
//        verifyPassword(plainPassword, storedPassword: storedPassword, encryptionKey: ENCRYPTION_KEY)
//    }
//
//    static func verifyPassword(_ plainPassword: String, storedPassword: String, encryptionKey: String) -> Bool {
//        guard !plainPassword.isEmpty, !storedPassword.isEmpty else { return false }
//        if looksEncrypted(storedPassword) {
//            let decrypted = decryptPassword(storedPassword, encryptionKey: encryptionKey)
//            let result = (plainPassword == decrypted)
//            print("🔐 Comparing with decrypted stored password: \(result)")
//            return result
//        } else {
//            let result = (plainPassword == storedPassword)
//            print("📝 Comparing with plain text stored password: \(result)")
//            return result
//        }
//    }
//
//    // ===== Helpers =====
//
//    private enum FernetError: Error {
//        case invalidToken
//        case unsupportedVersion
//        case tokenExpired
//        case badHMAC
//        case badEncoding
//    }
//
//    // base64url encode without padding
//    private static func base64UrlEncode(_ data: Data) -> String {
//        var s = data.base64EncodedString()
//        s = s.replacingOccurrences(of: "+", with: "-")
//             .replacingOccurrences(of: "/", with: "_")
//             .replacingOccurrences(of: "=", with: "")
//        return s
//    }
//
//    // base64url decode without padding
//    private static func base64UrlDecode(_ s: String) -> [UInt8]? {
//        var str = s.replacingOccurrences(of: "-", with: "+")
//                   .replacingOccurrences(of: "_", with: "/")
//        // Pad to multiple of 4
//        let pad = (4 - (str.count % 4)) % 4
//        if pad > 0 { str.append(String(repeating: "=", count: pad)) }
//        guard let data = Data(base64Encoded: str) else { return nil }
//        return Array(data)
//    }
//
//    // Accept either base64url or standard base64 for the key, with/without padding
//    private static func decodeBase64Either(_ s: String) -> [UInt8]? {
//        if let b = base64UrlDecode(s) { return b }
//        if let d = Data(base64Encoded: s) { return Array(d) }
//        return nil
//        }
//
//    private static func bigEndian8(_ x: UInt64) -> [UInt8] {
//        [
//            UInt8((x >> 56) & 0xff), UInt8((x >> 48) & 0xff),
//            UInt8((x >> 40) & 0xff), UInt8((x >> 32) & 0xff),
//            UInt8((x >> 24) & 0xff), UInt8((x >> 16) & 0xff),
//            UInt8((x >>  8) & 0xff), UInt8(x & 0xff)
//        ]
//    }
//
//    private static func toUInt64BE(_ bytes: [UInt8]) -> UInt64 {
//        var x: UInt64 = 0
//        for b in bytes { x = (x << 8) | UInt64(b) }
//        return x
//    }
//    /// Constant-time comparison to prevent timing attacks
//    private static func constantTimeEqual(_ a: [UInt8], _ b: [UInt8]) -> Bool {
//        guard a.count == b.count else { return false }
//        var diff: UInt8 = 0
//        for i in 0..<a.count {
//            diff |= a[i] ^ b[i]
//        }
//        return diff == 0
//    }
//}
