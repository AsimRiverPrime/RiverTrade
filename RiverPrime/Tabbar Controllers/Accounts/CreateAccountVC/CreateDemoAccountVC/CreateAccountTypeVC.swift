//
//  CreateAccountTypeVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 09/08/2024.
//

import UIKit
import Firebase

class CreateAccountTypeVC: BottomSheetController, CountryCurrencySelectionDelegate {
    
    
    @IBOutlet weak var lbl_accountTitle: UILabel!
    @IBOutlet weak var selectCurrencyBtn: UIButton!
    
    @IBOutlet weak var customNameBtn: UIButton!
    
    var userId : String = ""
    var userName:String = ""
    var currencyCode: String = ""
    var userEmail : String = ""
    
    @IBOutlet weak var tf_password: UITextField!
    
    @IBOutlet weak var btn_passowrdIcon: UIButton!
    
    @IBOutlet weak var lbl_passCaseOne: UILabel!
    @IBOutlet weak var lbl_passCaseTwo: UILabel!
    @IBOutlet weak var lbl_passCasethree: UILabel!
    
    let fireStoreInstance = FirestoreServices()
    let odooClientService = OdooClient()
//    let signViewModel = SignViewModel()
    
    var getSelectedAccountType = GetSelectedAccountType()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSelectedAccountValues()
        
        odooClientService.createUserAcctDelegate = self
        
        selectCurrencyBtn.addTarget(self, action: #selector(showCurrencies), for: .touchUpInside)
        tf_password.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        
        // Do any additional setup after loading the view.
        if let user = Auth.auth().currentUser {
            self.userEmail = user.email ?? ""
            self.userId = user.uid
        }
    }
    
    @objc func showCurrencies() {
        let countryCurrencyListVC = CountryCurrencyListViewController()
        countryCurrencyListVC.delegate = self  // Set the delegate
        let navigationController = UINavigationController(rootViewController: countryCurrencyListVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func didSelectCountryCurrency(countryName: String, currencyCode: String) {
        self.currencyCode = currencyCode
        selectCurrencyBtn.setTitle(currencyCode, for: .normal)
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        print("this is given name: \(userName)")
        print("this is select Currency: \(currencyCode)")
        print("this is given email: \(userEmail)")
        print("this is given password: \(self.tf_password.text ?? "")")
        
        odooClientService.createAccount(isDemo: true, group: self.lbl_accountTitle.text ?? "" , email: userEmail, currency: currencyCode, name: userName, password: (self.tf_password.text ?? ""))
    }
    
    @IBAction func pass_ShowHide_action(_ sender: Any) {
        self.tf_password.isSecureTextEntry = !self.tf_password.isSecureTextEntry
        self.btn_passowrdIcon.setImage(!self.tf_password.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func customNameBtnAction(_ sender: Any) {
    
        Alert.showTextFieldAlert(message: "Please enter your name", placeholder: "enter custom name", completion: { textFieldInput in
            if let name = textFieldInput {
                self.userName = name
                print("User entered: \(name)")
                self.customNameBtn.setTitle(name, for: .normal)
            } else {
                print("No input provided")
            }
        }, on: self)
        
    }
    
    @objc func passwordDidChange(_ textField: UITextField) {
//        if self.signViewModel.isValidatePassword(password: textField.text ?? ""){
//            
//        }else{
//            
//        }
        validatePassword(password: textField.text ?? "")
    }
    
    func validatePassword(password: String) {
        // Condition 1: Length between 8 and 15 characters
        if password.count >= 8 && password.count <= 15 {
            lbl_passCaseOne.textColor = .green
        } else {
            lbl_passCaseOne.textColor = .red
        }
        
        // Condition 2: At least one uppercase and one lowercase letter
        let uppercaseLetter = CharacterSet.uppercaseLetters
        let lowercaseLetter = CharacterSet.lowercaseLetters
        let hasUppercase = password.rangeOfCharacter(from: uppercaseLetter) != nil
        let hasLowercase = password.rangeOfCharacter(from: lowercaseLetter) != nil
        
        if hasUppercase && hasLowercase {
            lbl_passCaseTwo.textColor = .green
        } else {
            lbl_passCaseTwo.textColor = .red
        }
        
        // Condition 3: At least one number and one special character
        let numbers = CharacterSet.decimalDigits
        let specialCharacters = CharacterSet.punctuationCharacters.union(.symbols)
        let hasNumber = password.rangeOfCharacter(from: numbers) != nil
        let hasSpecial = password.rangeOfCharacter(from: specialCharacters) != nil
        
        if hasNumber && hasSpecial {
            lbl_passCasethree.textColor = .green
        } else {
            lbl_passCasethree.textColor = .red
        }
    }
    
    func updateUser(){
        
        var fieldsToUpdate: [String: Any] = [:]
        
        fieldsToUpdate = [
            "demoAccountCreated" : true
        ]
        
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("User demoAccountCreated fields updated successfully!")
                GlobalVariable.instance.isAccountCreated = true
                self.dismiss(animated: true, completion: {
                    print("Bottom sheet dismissed after success")
                })
            }
        }
    }

}

//MARK: - Set the selected account values here.
extension CreateAccountTypeVC {
    
    private func setSelectedAccountValues() {
        
        lbl_accountTitle.text = getSelectedAccountType.title
        
    }
    
}

extension CreateAccountTypeVC : CreateUserAccountTypeDelegate {
    func createAccountSuccess(response: Any) {
        print("\n this is create user success response: \(response)")
        updateUser()
    }
    
    func createAccountFailure(error: any Error) {
        print("\n this is create user error response: \(error)")
        
    }
}