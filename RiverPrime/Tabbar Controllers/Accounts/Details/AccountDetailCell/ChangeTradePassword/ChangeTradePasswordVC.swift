//
//  ChangeTradePasswordVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 09/12/2024.
//

import UIKit

class ChangeTradePasswordVC: BaseViewController {
   
    @IBOutlet weak var tf_oldPassword: UITextField!{
        didSet{
            
            tf_oldPassword.setIcon(UIImage(imageLiteralResourceName: "passwordIcon").tint(with: UIColor(red: 161/255.0, green: 165/255.0, blue: 183/255.0, alpha: 1.0)))
        }
    }
    @IBOutlet weak var tf_newPassword: UITextField!{
        didSet{
         
            tf_newPassword.setIcon(UIImage(imageLiteralResourceName: "passwordIcon").tint(with: UIColor(red: 161/255.0, green: 165/255.0, blue: 183/255.0, alpha: 1.0)))
        }
    }

    @IBOutlet weak var lbl_oldPassword: UILabel!
    @IBOutlet weak var btn_OldPassowrdIcon: UIButton!
    @IBOutlet weak var btn_NewPassowrdIcon: UIButton!
    
    @IBOutlet weak var lbl_passCaseOne: UILabel!
    @IBOutlet weak var lbl_passCaseTwo: UILabel!
    @IBOutlet weak var lbl_passCasethree: UILabel!
    
    let fireStoreInstance = FirestoreServices()
    let odooClientService = OdooClientNew()
    
    var loginID : Int?
    var userEmail : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_oldPassword.isHidden = true
        
        tf_newPassword.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        
        if let data = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(data)")
            
            if let loginId = data["loginId"] as? Int, let email1 = data["email"] as? String  {
                print("login ID: \(loginId)")
                self.loginID = loginId
                self.userEmail = email1
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // This will dismiss the keyboard
    }
    
    func isPasswordValid(inputPassword: String) -> Bool {
        // Retrieve the stored password from UserDefaults
        guard let storedPassword = UserDefaults.standard.string(forKey: "password") else {
            print("No password found in UserDefaults")
            return false
        }
        print("Old Password is:\(storedPassword)")
        // Compare the input password with the stored password
        return storedPassword == inputPassword
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        guard let inputPassword = tf_oldPassword.text, !inputPassword.isEmpty else {
                print("Password field is empty")
                return
            }
            
            if isPasswordValid(inputPassword: inputPassword) {
                print("Passwords match with old one:\(inputPassword)")
                // Proceed with login
            } else {
                print("\nPasswords do not match!:\(inputPassword)")
                lbl_oldPassword.isHidden = false
                return
            }
        
        print("this is given password: \(self.tf_newPassword.text ?? "")")
        if inputPassword == tf_newPassword.text {
            lbl_oldPassword.isHidden = false
            lbl_oldPassword.text = "Passwords should not be the same"
            return
        }else{
            lbl_oldPassword.isHidden = true
            UserDefaults.standard.set((self.tf_newPassword.text ?? ""), forKey: "password")
            
            odooClientService.updateMTUserNamePassword(email: userEmail, loginID: loginID ?? 0 , oldPassword: self.tf_oldPassword.text ?? "", newPassword: self.tf_newPassword.text ?? "", userName: "")
        }
    }
    
    @IBAction func close_btnAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func pass_ShowHideOldPass_action(_ sender: Any) {
        self.tf_oldPassword.isSecureTextEntry = !self.tf_oldPassword.isSecureTextEntry
        self.btn_OldPassowrdIcon.setImage(!self.tf_oldPassword.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func pass_ShowHideNewPass_action(_ sender: Any) {
        self.tf_newPassword.isSecureTextEntry = !self.tf_newPassword.isSecureTextEntry
        self.btn_NewPassowrdIcon.setImage(!self.tf_newPassword.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    
    @objc func passwordDidChange(_ textField: UITextField) {
        
        validatePassword(password: textField.text ?? "")
    }
    
    func validatePassword(password: String) {
        // Condition 1: Length between 8 and 15 characters
        if password.count >= 8 /*&& password.count <= 15*/ {
            lbl_passCaseOne.textColor = .systemGreen
        } else {
            lbl_passCaseOne.textColor = .systemRed
        }
        
        // Condition 2: At least one uppercase and one lowercase letter
        let uppercaseLetter = CharacterSet.uppercaseLetters
        let lowercaseLetter = CharacterSet.lowercaseLetters
        let hasUppercase = password.rangeOfCharacter(from: uppercaseLetter) != nil
        let hasLowercase = password.rangeOfCharacter(from: lowercaseLetter) != nil
        
        if hasUppercase && hasLowercase {
            lbl_passCaseTwo.textColor = .systemGreen
        } else {
            lbl_passCaseTwo.textColor = .systemRed
        }
        
        // Condition 3: At least one number and one special character
        let numbers = CharacterSet.decimalDigits
        let specialCharacters = CharacterSet.punctuationCharacters.union(.symbols)
        let hasNumber = password.rangeOfCharacter(from: numbers) != nil
        let hasSpecial = password.rangeOfCharacter(from: specialCharacters) != nil
        
        if hasNumber && hasSpecial {
            lbl_passCasethree.textColor = .systemGreen
        } else {
            lbl_passCasethree.textColor = .systemRed
        }
}
}

extension ChangeTradePasswordVC: UpdateUserNamePassword {
    func updateSuccess(response: Any) {
        print("sucess response of update password: \(response)")
    }
    
    func updateFailure(error: any Error) {
        print("Error response of update password: \(error)")
    }
    
   
}
