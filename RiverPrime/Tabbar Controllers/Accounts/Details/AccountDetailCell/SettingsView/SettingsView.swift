//
//  SettingsView.swift
//  RiverPrime
//
//  Created by abrar ul haq on 26/10/2024.
//

import UIKit

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
    
    
    
    public override func awakeFromNib() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let loginID = savedUserData["loginId"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool, let accountType = savedUserData["demoAccountGroup"] as? String, let isRealAccount = savedUserData["realAccountCreated"] as? Bool  {
                
                self.lbl_accountNumber.text = "#\(loginID)"
                self.lbl_loginID.text = "\(loginID)"
                
                if isCreateDemoAccount == true {
                    self.lbl_accountType.text = " Demo "
                    self.lbl_serverType.text = " MT5 "
                    self.lbl_accountGroup.text = " \(accountType) "
                }
                if isRealAccount == true {
                    self.lbl_accountType.text = " Real "
                    self.lbl_serverType.text = " MT5 "
                    self.lbl_accountGroup.text = " \(accountType) "
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
        self.lbl_serverName.text = "RiverPrimeLimited-Demo"
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
        
    }
    
    
}