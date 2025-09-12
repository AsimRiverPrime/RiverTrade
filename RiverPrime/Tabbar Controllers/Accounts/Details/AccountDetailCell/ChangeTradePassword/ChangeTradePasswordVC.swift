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
    @IBOutlet weak var lbl_passCasefourth: UILabel!
    
    let fireStoreInstance = FirestoreServices()
    let odooClientUpadePassword = OdooClientNew()
    let passwordManager = PasswordManager()
    
    
    var loginID : Int?
    var userEmail : String = ""
    var isDemo = Bool()
    var oldPassword = String()
    var newPassword = String()
    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_oldPassword.isHidden = true
        
         odooClientUpadePassword.updateUserNamePasswordDelegate = self
        
        tf_newPassword.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        
        if let data = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(data)")
            
            if let email1 = data["email"] as? String, let _uid = data["uid"] as? String  {
                self.userID = _uid
                self.userEmail = email1
            }
        }
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
                  self.loginID = defaultAccount.accountNumber
                  
                  isDemo = !defaultAccount.isReal
                  oldPassword = defaultAccount.password
              }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // This will dismiss the keyboard
    }
    
    func isPasswordValid(inputPassword: String) -> Bool {
        // Retrieve the stored password from UserDefaults
//        guard let storedPassword = UserDefaults.standard.string(forKey: "password") else {
//            print("No password found in UserDefaults")
//            return false
//        }
        print("Old Password is:\(oldPassword)")
        let decryptePassword = PasswordEncryption.decryptPassword(oldPassword)
        print("Old Password decryptePassword is:\(decryptePassword)")
        // Compare the input password with the stored password
        return decryptePassword == inputPassword
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        guard let inputPassword = tf_oldPassword.text, !inputPassword.isEmpty else {
                print("Password field is empty")
            self.ToastMessage("Old password field is empty")
                return
            }
        guard let newPassword = tf_newPassword.text, !newPassword.isEmpty else {
                print("Password field is empty")
            self.ToastMessage("New password field is empty")
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
            let oldPassword = PasswordEncryption.encryptPassword(self.tf_oldPassword.text ?? "")
            let newPassword = PasswordEncryption.encryptPassword(self.tf_newPassword.text ?? "")
            print("Both passwords encrypted successfuly")
            UserDefaults.standard.set(newPassword, forKey: "password")
            self.newPassword = newPassword
            
            if validatePassword(self.tf_newPassword.text ?? "") {
                odooClientUpadePassword.updateMTUserNamePassword(email: userEmail, loginID: loginID ?? 0 , oldPassword: oldPassword /*self.tf_oldPassword.text ?? ""*/, newPassword: newPassword /*self.tf_newPassword.text ?? ""*/, userName: "", isdemo: isDemo)
            } else {
               self.ToastMessage("Password does not meet requirements")
           }
             
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
        
        validatePassword(textField.text ?? "")
    }
    
    func validatePassword(_ password: String) -> Bool {
        var isValid = true
        
        // Condition 1: Length between 8 and 15 characters
        if password.count >= 8 && password.count <= 15 {
            lbl_passCaseOne.textColor = .systemGreen
        } else {
            lbl_passCaseOne.textColor = .systemRed
            isValid = false
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
            isValid = false
        }
        
        // Condition 3: At least one number
        
        let numbers = CharacterSet.decimalDigits
        let hasNumber = password.rangeOfCharacter(from: numbers) != nil
        
        if hasNumber {
            lbl_passCasethree.textColor = .systemGreen
        } else {
            lbl_passCasethree.textColor = .systemRed
            isValid = false
        }
        
        // Condition 4: At least one special character
        let specialCharacters = CharacterSet.punctuationCharacters.union(.symbols)
        let hasSpecial = password.rangeOfCharacter(from: specialCharacters) != nil
        
        if hasSpecial {
            lbl_passCasefourth.textColor = .systemGreen
        } else {
            lbl_passCasefourth.textColor = .systemRed
            isValid = false
        }
        
        return isValid
    }
}

extension ChangeTradePasswordVC: UpdateUserNamePassword {
    func updateSuccess(response: Any) {
        print("sucess response of update password: \(response)")

        if let dict = response as? [String: Any],
           let result = dict["result"] as? [String: Any],
           let success = result["success"] as? Int {
            
            if success == 1 {
                // ✅ Show success toast
                self.ToastMessage("Password updated successfully")
                
                self.fireStoreInstance.updatePassword(for: String(self.loginID ?? 0) , userId: self.userID , newPassword: newPassword) { [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        print("Error updating default account: \(error.localizedDescription)")
                        return
                    }
                    print("password added successfully.")
                    
                    if self.passwordManager.savePassword(for: String(self.loginID ?? 0), password:  newPassword) {
                        print("Password successfully saved from loginScreen.")
                    } else {
                        print("ID already exists. Cannot save password.")
                    }
                    
                    let allPasswords = self.passwordManager.getAllPasswords()
                    print("All Saved Passwords on from loginScreen: \(allPasswords)")
                    
                    //                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.MetaTraderLoginConstant.key, dict: [NotificationObserver.Constants.MetaTraderLoginConstant.title: self.metaTraderType ?? MetaTraderType.None])
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                // ❌ Failed case
                self.ToastMessage("Password update failed, please try again later.")
            }
        }
    }

    func updateFailure(error: any Error) {
        print("Error response of update password: \(error)")
        self.ToastMessage("Something went wrong. Please try again.")
    }
}
