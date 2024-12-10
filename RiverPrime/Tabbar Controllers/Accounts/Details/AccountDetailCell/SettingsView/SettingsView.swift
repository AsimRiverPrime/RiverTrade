//
//  SettingsView.swift
//  RiverPrime
//
//  Created by abrar ul haq on 26/10/2024.
//

import UIKit

protocol ChangePasswordDelegate: AnyObject {
    func didTapButton()
}

class SettingsView: UIView {
    
    @IBOutlet weak var lbl_accountType: UILabel!
    @IBOutlet weak var lbl_serverType: UILabel!
    @IBOutlet weak var lbl_accountGroup: UILabel!
    
    @IBOutlet weak var lbl_accountNumber: UILabel!
    @IBOutlet weak var lbl_acctUserName: UILabel!
    
    @IBOutlet weak var lbl_commission: UILabel!
    
    @IBOutlet weak var lbl_minimiumSpread: UILabel!
    @IBOutlet weak var lbl_maximumLeverage: UILabel!
    
    @IBOutlet weak var lbl_loginID: UILabel!
    @IBOutlet weak var lbl_serverName: UILabel!
    
    weak var changePassDelegate : ChangePasswordDelegate?
    let odooClientService = OdooClientNew()
    weak var updateUserNameDelegate : UpdateUserNamePassword?
    
    var userEmail: String?
    
    public override func awakeFromNib() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let loginID = savedUserData["loginId"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool, let accountType = savedUserData["demoAccountGroup"] as? String, let isRealAccount = savedUserData["realAccountCreated"] as? Bool, let _email = savedUserData["email"] as? String  {
//                self.lbl_acctUserName.text = _name
                let storedUserName = UserDefaults.standard.string(forKey: "MTUserName")
                self.lbl_acctUserName.text = storedUserName
                
                self.lbl_accountNumber.text = "#\(loginID)"
                self.lbl_loginID.text = "\(loginID)"
                self.userEmail = _email
                
                if isCreateDemoAccount == true {
                    self.lbl_accountType.text = " Demo "
//                    self.lbl_serverType.text = " MT5 "
                    self.lbl_accountGroup.text = " \(accountType) "
                    self.lbl_serverName.text = "DEMO-Server"
                }
                if isRealAccount == true {
                    self.lbl_accountType.text = " Real "
//                    self.lbl_serverType.text = " MT5 "
                    self.lbl_accountGroup.text = " \(accountType) "
                    self.lbl_serverName.text = "REAL-Server"
                }
                if accountType == "Pro Account" {
                    self.lbl_accountGroup.text = " PRO "
                    
                }else if accountType == "Prime Account" {
                    self.lbl_accountGroup.text = " PRIME "
                    
                }else if accountType == "Premium Account" {
                    self.lbl_accountGroup.text = " PREMIUM "
                    
                }
                
            }
        }
        
    }
    
    class func getView()->SettingsView {
        return Bundle.main.loadNibNamed("SettingsView", owner: self, options: nil)?.first as! SettingsView
    }
    
    func dismissView() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0.04,
            animations: {
                self.alpha = 0
            }, completion: { (complete) in
                self.removeFromSuperview()
            })
    }
    
    @IBAction func copyLoginID_action(_ sender: Any) {
        
    }
    
    @IBAction func changePassword_action(_ sender: Any) {
        changePassDelegate?.didTapButton()
    }
    
    @IBAction func addCustomName(_ sender: Any) {
        let storedPassword = UserDefaults.standard.string(forKey: "password")
        
        Alert.showTextFieldAlertView(message: "Please enter your name", placeholder: "enter custom name", completion: { textFieldInput in
            if let name = textFieldInput {
                //                    self.userName = name
                print("User entered: \(name)")

                self.odooClientService.updateMTUserNamePassword(email: self.userEmail ?? "", loginID: Int(self.lbl_loginID.text ?? "") ?? 0 , oldPassword: storedPassword ?? "", newPassword: "", userName: name)
                UserDefaults.standard.set(name, forKey: "MTUserName")
                self.lbl_acctUserName.text = name
                
            } else {
                print("No input provided")
            }
        }, on: self)
        
    }
}
extension SettingsView: UpdateUserNamePassword {
    func updateSuccess(response: Any) {
        print("update MT User Name sucess response: \(response) ")
    }
    
    func updateFailure(error: any Error) {
        print("update MT User Name failed response: \(error) ")
    }
    
}
extension UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
