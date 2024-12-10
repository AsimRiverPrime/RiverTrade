//
//  FundsView.swift
//  RiverPrime
//
//  Created by abrar ul haq on 25/10/2024.
//

import UIKit

class FundsView: UIView {
    
    @IBOutlet weak var lbl_loginID: UILabel!
    @IBOutlet weak var lbl_acctType: UILabel!
    @IBOutlet weak var lbl_mt: UILabel!
    @IBOutlet weak var lbl_acctGroup: UILabel!
    
    @IBOutlet weak var lbl_balance: UILabel!
    @IBOutlet weak var lbl_equity: UILabel!
    @IBOutlet weak var lbl_totalPL: UILabel!
    @IBOutlet weak var lbl_Margin: UILabel!
    @IBOutlet weak var lbl_freeMargin: UILabel!
    @IBOutlet weak var lbl_marginLevel: UILabel!
    @IBOutlet weak var lbl_leverage: UILabel!
    
    
    
    public override func awakeFromNib() {
        setHeaderValue()
    }
    
    func setHeaderValue() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let loginID = savedUserData["loginId"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool, let accountType = savedUserData["demoAccountGroup"] as? String, let isRealAccount = savedUserData["realAccountCreated"] as? Bool  {
                
                self.lbl_acctGroup.text = " \(accountType) "
                
                self.lbl_loginID.text = "#\(loginID)"
                if isCreateDemoAccount {
                    self.lbl_acctType.text = " Demo "
                }
                if isRealAccount {
                    self.lbl_acctType.text = " Real "
                }
                
                if accountType == "Pro Account" {
                    self.lbl_acctGroup.text = " PRO "
                }else if accountType == "Prime Account" {
                    self.lbl_acctGroup.text  = " PRIME "
                }else if accountType == "Premium Account" {
                    self.lbl_acctGroup.text  = " PREMIUM "
                }
            }
        }
        
        if let user = UserManager.shared.currentUser {
            print("\n User Balance: \(user)")
            self.lbl_balance.text = "\(user.balance)"
            self.lbl_equity.text = "\(user.equity)"
            self.lbl_leverage.text = "\(user.leverage)"
            self.lbl_totalPL.text = "\(user.profit)"
            self.lbl_Margin.text = "\(user.margin)"
            self.lbl_freeMargin.text = "\(user.marginFree)"
            let marginLevelValue = "\(user.marginLevel)".trimmedTrailingZeros()
            self.lbl_marginLevel.text = marginLevelValue + "%"
            
        }
        
    }
    
    class func getView()->FundsView {
        return Bundle.main.loadNibNamed("FundsView", owner: self, options: nil)?.first as! FundsView
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
    
}
