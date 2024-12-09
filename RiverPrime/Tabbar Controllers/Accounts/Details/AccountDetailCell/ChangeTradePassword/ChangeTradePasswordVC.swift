//
//  ChangeTradePasswordVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 09/12/2024.
//

import UIKit

class ChangeTradePasswordVC: BaseViewController {
    
    var userId : String = ""
    var userName:String = ""
   
    var userEmail : String = ""
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        odooClientService.createUserAcctDelegate = self
        
        tf_newPassword.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        
        if let data = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(data)")
            
            if let userIdSave = data["uid"] as? String, let email1 = data["email"] as? String  {
                print("user ID: \(userIdSave)")
                self.userId = userIdSave
                self.userEmail = email1
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // This will dismiss the keyboard
    }
    
    
    @IBAction func submitBtnAction(_ sender: Any) {
        print("this is given old password: \(userName)")
        
        print("this is given password: \(self.tf_newPassword.text ?? "")")
        let phone =  UserDefaults.standard.string(forKey: "phoneNumber")
        let Firstname = UserDefaults.standard.string(forKey: "firstName")
        let LastName = UserDefaults.standard.string(forKey: "lastName")
        
        UserDefaults.standard.set((self.tf_newPassword.text ?? ""), forKey: "password")
        
        
        //        odooClientService.createAccount(isDemo: true, group: self.lbl_accountTitle.text ?? "" , email: userEmail, currency: currencyCode, name: userName, password: (self.tf_password.text ?? ""))
//        odooClientService.createAccount(phone: phone ?? "", group: group, email: userEmail, currency: currencyCode, leverage: 100, first_name: Firstname ?? "", last_name: LastName ?? "", password: (self.tf_password.text ?? ""))
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
        if password.count >= 8 && password.count <= 15 {
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
    
func updateUser(){
        
        var fieldsToUpdate: [String: Any] = [:]
        
        fieldsToUpdate = [
          
            "loginId" : GlobalVariable.instance.loginID // loginID in response
        ]
        
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("User demoAccountCreated fields updated successfully!")
                GlobalVariable.instance.isAccountCreated = true
                self.fireStoreInstance.fetchUserData(userId: self.userId)
                self.dismiss(animated: true, completion: {
                    print("Bottom sheet dismissed after success")
                    // notification send to dashboardvc
                    let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        
                        NotificationCenter.default.post(name: NSNotification.Name("accountCreate"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name("metaTraderLogin"), object: nil)
                    }
                    
                    
                })
            }
        }
    }
}

extension ChangeTradePasswordVC : CreateUserAccountTypeDelegate {
    func createAccountSuccess(response: Any) {
        print("\n this is create user success response: \(response)")
        // get loginId from the response
        
        updateUser()
    }
    
    func createAccountFailure(error: any Error) {
        print("\n this is create user error response: \(error)")
        
    }
}
