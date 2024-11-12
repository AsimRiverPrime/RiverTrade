//
//  SignViewModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 15/07/2024.
//

import Foundation


 class SignViewModel {
    
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isLoginFieldsValid(email: String, password: String) -> Bool {
        
        if !email.isEmpty && self.isValidEmail(email) && !password.isEmpty && isValidatePassword(password: password) {
            return true
        }
        return false
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        if !password.isEmpty && password.count >= 8 {
            return true
        }
        return false
        
    }
     
     func isValidatePassword(password: String) -> Bool {
        
         // Condition 2: At least one uppercase and one lowercase letter
         let uppercaseLetter = CharacterSet.uppercaseLetters
         let lowercaseLetter = CharacterSet.lowercaseLetters
         let hasUppercase = password.rangeOfCharacter(from: uppercaseLetter) != nil
         let hasLowercase = password.rangeOfCharacter(from: lowercaseLetter) != nil
         
         // Condition 3: At least one number and one special character
         let numbers = CharacterSet.decimalDigits
         let specialCharacters = CharacterSet.punctuationCharacters.union(.symbols)
         let hasNumber = password.rangeOfCharacter(from: numbers) != nil
         let hasSpecial = password.rangeOfCharacter(from: specialCharacters) != nil
         
         // Condition 1: Length between 8 and   15 characters (&& password.count <= 15)
     if password.count >= 8 && hasUppercase && hasLowercase && hasNumber && hasSpecial {
         return true
     } else {
         return false
     }
  
     }
     

}
