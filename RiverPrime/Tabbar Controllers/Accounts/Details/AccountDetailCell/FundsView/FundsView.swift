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
    @IBOutlet weak var lbl_spreadFrom: UILabel!
    @IBOutlet weak var lbl_commission: UILabel!
    @IBOutlet weak var lbl_startDeposit: UILabel!
    @IBOutlet weak var lbl_stepOut: UILabel!
    
    
    public override func awakeFromNib() {
        setHeaderValue()
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
    }
    @objc func notificationPopup(_ notification: NSNotification) {
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received amount in Funds: \(ammount)")
           
            
            if let user = UserManager.shared.currentUser {
                self.lbl_balance.text = "$\(user.balance)"
                self.lbl_equity.text = "$\(ammount)"
                let totalPL = (Double(ammount) ?? 0.0) - (user.balance)
                let freeMargin = (Double(ammount) ?? 0.0) - (user.margin)
               
                self.lbl_leverage.text = "1:\(user.leverage)"
                self.lbl_totalPL.text = "$"+"\(totalPL)".trimmedTrailingZeros()
                self.lbl_Margin.text = "$\(user.margin)"
                self.lbl_freeMargin.text = "$"+"\(freeMargin)".trimmedTrailingZeros()
                
                
                if user.margin == 0.0 {
                    self.lbl_marginLevel.text = "0%"
                }else{
                    let marginLevel = (Double(ammount) ?? 0.0) / (user.margin) * 100
                    let marginLevelValue = "\(marginLevel)".trimmedTrailingZeros()
                    self.lbl_marginLevel.text = marginLevelValue + "%"
                }
            }
            
        }
        
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
