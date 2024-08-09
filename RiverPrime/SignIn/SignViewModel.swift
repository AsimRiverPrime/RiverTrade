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
        
        if !email.isEmpty && self.isValidEmail(email) && !password.isEmpty && password.count >= 6 {
            return true
        }
        return false
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        if !password.isEmpty && password.count >= 6 {
            return true
        }
        return false
    }
     
     

}
