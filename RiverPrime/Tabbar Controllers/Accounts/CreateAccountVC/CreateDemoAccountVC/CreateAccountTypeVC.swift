//
//  CreateAccountTypeVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 09/08/2024.
//

import UIKit
import Foundation
import Firebase
import CryptoKit
import CommonCrypto


class CreateAccountTypeVC: BottomSheetController, CountryCurrencySelectionDelegate {
    
    @IBOutlet weak var lbl_accountTitle: UILabel!
    @IBOutlet weak var selectCurrencyBtn: UIButton!
    
    @IBOutlet weak var customNameBtn: UIButton!
    
    var userId : String = ""
    var userName:String = ""
    var currencyCode: String = ""
    var userEmail : String = ""
    var isReal = Bool()
    
    @IBOutlet weak var tf_password: UITextField!
    
    @IBOutlet weak var btn_passowrdIcon: UIButton!
    
    @IBOutlet weak var lbl_passCaseOne: UILabel!
    @IBOutlet weak var lbl_passCaseTwo: UILabel!
    @IBOutlet weak var lbl_passCasethree: UILabel!
    
    let fireStoreInstance = FirestoreServices()
    let odooClientService = OdooClientNew()
//    let signViewModel = SignViewModel()
    
//    var getSelectedAccountType = GetSelectedAccountType()
    var account: AccountModel?
//    let aesPasswordKey = "mySecretpasswordKey".data(using: .utf8)!
    var getbalanceApi = TradeTypeCellVM()
    var  group = String()
    var demoAccountGroup = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let account = account {
                    print("Received Account info: \(account.name)  and with account!.leverage: \(account.leverage)\n with all account detail is \(account)")
                    // Use account data to update UI
                }
      
//        lbl_accountTitle.text = getSelectedAccountType.title
        lbl_accountTitle.text = "\(account!.name.uppercased()) Account"
        odooClientService.createUserAcctDelegate = self
        
        selectCurrencyBtn.addTarget(self, action: #selector(showCurrencies), for: .touchUpInside)
        tf_password.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
    
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
    
    func validateInputs() -> Bool {
        guard !userName.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.ToastMessage("Please enter your username.")
            return false
        }
        
        guard !currencyCode.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.ToastMessage("Please select a currency code.")
            return false
        }
        
        guard !(self.tf_password.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty else {
            self.ToastMessage("Please enter your password.")
            return false
        }
        
        return true
    }
    

    func canCreateNewAccount(for userID: String) -> Bool {
        // Retrieve the saved data from UserDefaults
        guard let accountsData = UserDefaults.standard.dictionary(forKey: "userAccountsData") as? [String: [String: Any]] else {
            print("No accounts found in UserDefaults.")
            return true
        }
        
        // Filter accounts for the given userID
        let userAccounts = accountsData.values.filter { account in
            account["userID"] as? String == userID
        }
        
        // Define required groups
        let requiredGroups: Set<String> = ["PREMIUM", "PRO", "PRIME"]
        
        // Check if the user already has accounts with `isReal = 1` in all required groups
        let realAccounts = userAccounts.filter { ($0["isReal"] as? Int ?? 0) == 1 }
        let realGroupNames = realAccounts.compactMap { $0["groupName"] as? String }
        let realGroupsSet = Set(realGroupNames)
        if requiredGroups.isSubset(of: realGroupsSet) {
            showAlert(message: "You already have Real accounts with PREMIUM, PRO, and PRIME Types.")
            return false
        }
        
        // Check if the user already has accounts with `isReal = 0` in all required groups
        let demoAccounts = userAccounts.filter { ($0["isReal"] as? Int ?? 0) == 0 }
        let demoGroupNames = demoAccounts.compactMap { $0["groupName"] as? String }
        let demoGroupsSet = Set(demoGroupNames)
        if requiredGroups.isSubset(of: demoGroupsSet) {
            showAlert(message: "You already have Demo accounts in PREMIUM, PRO, and PRIME Types.")
            return false
        }
        
        return true
    }

    func showAlert(message: String) {
        print("Alert: \(message)") // Replace with your alert presentation logic (e.g., UIAlertController in iOS)
//        Alert.showAlert(withMessage: message, andTitle: "Warraning!", on: UIViewController?.none)
        
        let alert = UIAlertController(title: "Warraning!", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
             }))
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func submitBtnAction(_ sender: Any) {
        if !validateInputs() {
            return
        }
        
        print("this is given name: \(userName)")
        print("this is select Currency: \(currencyCode)")
        print("this is given email: \(userEmail)")
        print("this is given password: \(self.tf_password.text ?? "")")
        let phone =  UserDefaults.standard.string(forKey: "phoneNumber")
        let Firstname = UserDefaults.standard.string(forKey: "firstName")
        let LastName = UserDefaults.standard.string(forKey: "lastName")
        print("this is phoneNumber:\(phone) firstName:\(Firstname) lastName:\(LastName): leravage: \(account!.leverage)")
        UserDefaults.standard.set((self.tf_password.text ?? ""), forKey: "password")
        UserDefaults.standard.set(userName, forKey: "MTUserName")
        
        if self.lbl_accountTitle.text == "PRO Account" {
             group = "demo\\RP\\PRO"
            demoAccountGroup = "PRO"
        }else if self.lbl_accountTitle.text == "PRIME Account" {
             group = "demo\\RP\\Prime"
            demoAccountGroup = "PRIME"
        }else {
             group = "demo\\RP\\Premium"
            demoAccountGroup = "PREMIUM"
        }
        
        if canCreateNewAccount(for: userId) {
              // Allowed to create a new account
            if isReal {
                odooClientService.createAccount(phone: phone ?? "", group: group, email: userEmail, currency: currencyCode, leverage: 400 /*Int(account!.leverage) ?? 0*/, first_name: userName , last_name: "", password: (self.tf_password.text ?? ""), is_demo: false)
            }else{
                odooClientService.createAccount(phone: phone ?? "", group: group, email: userEmail, currency: currencyCode, leverage: 400 /*Int(account!.leverage) ?? 0*/, first_name: userName , last_name: "", password: (self.tf_password.text ?? ""), is_demo: true)
            }
              print("Account created successfully!")
          } else {
              // Not allowed to create a new account (Alert is already shown by `canCreateNewAccount`)
              print("Failed to create account due to restrictions.")
          }
        
       
    }
    
    @IBAction func pass_ShowHide_action(_ sender: Any) {
        self.tf_password.isSecureTextEntry = !self.tf_password.isSecureTextEntry
        self.btn_passowrdIcon.setImage(!self.tf_password.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func customNameBtnAction(_ sender: Any) {
    
        Alert.showTextFieldAlert(message: "Please enter your name for Meta Trader Account", placeholder: "enter custom name", completion: { textFieldInput in
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
            "demoAccountCreated" : !isReal,
            "realAccountCreated" : isReal,
            "demoAccountGroup" : self.demoAccountGroup ,
            "loginId" : GlobalVariable.instance.loginID, // loginID in response
            "registrationType": 1
        ]
        
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("User demoAccountCreated fields updated successfully!")
                GlobalVariable.instance.isAccountCreated = true
                self.fireStoreInstance.fetchUserData(userId: self.userId)
                self.fireStoreInstance.fetchUserAccountsData(userId: self.userId)
              //  self.dismiss(animated: true, completion: {
                    print("Bottom sheet dismissed after success")
                    // notification send to dashboardvc
                    let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                      
                        NotificationCenter.default.post(name: NSNotification.Name("accountCreate"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name("metaTraderLogin"), object: nil)
                    }
                    
                       
//                })
            }
        }
    }
 // MARK: - New work flow
    func updateUserAccount(){
        
        var fieldsToUpdate: [String:Any] = [
            "KycStatus": "Not Started",
            "name" : self.userName,
            "currency": self.currencyCode,
            "userID" : userId,
            "groupID": account?.id ?? "",
            "isDefault" : true,
            "isReal": isReal,
            "groupName" : self.demoAccountGroup,
            "accountNumber" : GlobalVariable.instance.loginID // loginID in createAccount response
        ]
       
        print("updating fields are: \(fieldsToUpdate)")
        fireStoreInstance.updateUserAccountsFields(fields: fieldsToUpdate, completion: { error in
            if let error = error {
                print("Error updating UserAccounts fields: \(error.localizedDescription)")
                return
            } else {
                print("User Accounts fields updated successfully!")
                GlobalVariable.instance.isAccountCreated = true
                
                self.fireStoreInstance.updateDefaultAccount(for: "\(GlobalVariable.instance.loginID)", isNewAccount:  true , newAccountData: fieldsToUpdate)
                
                self.fireStoreInstance.fetchUserData(userId: self.userId)
                _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                   
                    self.getbalanceApi.getBalance(completion: { response in
                        print("response of get balance: \(response)")
                        if response == "Invalid Response" {
                            //                            self.balance = "0.0"
                            return
                        }
                        //                        self.balance = response
                        GlobalVariable.instance.balanceUpdate = response //self.balance
                        print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
                    })
                    
                    NotificationCenter.default.post(name: NSNotification.Name("accountCreate"), object: nil) // modify with abrar bhai
                    NotificationCenter.default.post(name: NSNotification.Name("metaTraderLogin"), object: nil)
                }
               
                if self.isReal {
                    let forKYC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
                    PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: forKYC!)
                    self.dismiss(animated: true)
                }else{
                    self.dismiss(animated: true)
                    
                }
            }
        })
    }
    
}


extension CreateAccountTypeVC : CreateUserAccountTypeDelegate {
    func createAccountSuccess(response: Any) {
        print("\nthis is create user success response: \(response)")
        // get loginId from the response
        updateUserAccount()
        updateUser()
        showTimeAlert(str: "Account Create Sucessfully.")
    }
    
    func createAccountFailure(error: any Error) {
        print("\n this is create user error response: \(error)")
        showTimeAlert(str: "Account Create Failed.")
    }
}
