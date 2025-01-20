//
//  FundsView.swift
//  RiverPrime
//
//  Created by Ross Rostane on 25/10/2024.
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
    @IBOutlet weak var lbl_totalWithdrawal: UILabel!
    @IBOutlet weak var lbl_totalDeposit: UILabel!
    
    
    var accountsGroup: [AccountModel]?
    var fireStoreInstance = FirestoreServices()
    var userGroupID = String()
    
    public override func awakeFromNib() {
        
        self.fireStoreInstance.fetchAccountsGroup { [weak self] fetchedAccounts in
            guard let self = self else { return }
            print("fetchedAccounts Groups: \(fetchedAccounts)")
            
            accountsGroup = fetchedAccounts
            
            
        }
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            print("\n Default Account user in fundsView : \(defaultAccount)")
            self.lbl_loginID.text = "#\(defaultAccount.accountNumber)"
            lbl_acctType.text = defaultAccount.isReal == true ? "Real" : "Demo"
            self.lbl_acctGroup.text = defaultAccount.groupName
            self.userGroupID = defaultAccount.groupID
            
            print("accountsGroup : \(accountsGroup) , defaultAccount.groupID: \(defaultAccount.groupID)")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
    }
    
    func getAccountDetails(by id: String) -> AccountModel? {
        return accountsGroup!.first { $0.id == id }
    }
    
    @objc func notificationPopup(_ notification: NSNotification) {
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received amount in Funds: \(ammount)")
            
            if let user = UserManager.shared.currentUser {
//                self.lbl_balance.text = "$\(user.balance)"
              
                    self.lbl_balance.text = "$\(String.formatStringNumber(String(user.balance)))"
                
                self.lbl_equity.text = "$\(String.formatStringNumber(String(ammount)))" //"$\(ammount)"
                let totalPL = (Double(ammount) ?? 0.0) - (user.balance)
                let freeMargin = (Double(ammount) ?? 0.0) - (user.margin)
              
                    self.lbl_totalDeposit.text = "$\(String.formatStringNumber(String(user.totalDeposit)))"
                
//                self.lbl_totalDeposit.text = "$\(user.totalDeposit)"
                    self.lbl_totalWithdrawal.text = "$\(String.formatStringNumber(String(user.totalWithdraw)))"
//                self.lbl_totalWithdrawal.text = "$\(user.totalWithdraw)"
               
                self.lbl_totalPL.text = "$\(String.formatStringNumber(String(totalPL)))" //"$"+"\(totalPL)".trimmedTrailingZeros()
                self.lbl_Margin.text = "$\(user.margin)"
                self.lbl_freeMargin.text = "$\(String.formatStringNumber(String(freeMargin)))" //"$"+"\(freeMargin)".trimmedTrailingZeros()
                
                if user.margin == 0.0 {
                    self.lbl_marginLevel.text = "0%"
                }else{
                    let marginLevel = (Double(ammount) ?? 0.0) / (user.margin) * 100
                    let marginLevelValue = "\(marginLevel)".trimmedTrailingZeros()
                    self.lbl_marginLevel.text = marginLevelValue + "%"
                }
                print("user balance values: \(user)")
            }
            
            if let selectedAccount = getAccountDetails(by: self.userGroupID) {
                print("userGroupID:\(userGroupID) and selected Account is : \(selectedAccount)")
                self.lbl_leverage.text = selectedAccount.leverage
                lbl_spreadFrom.text = selectedAccount.spreadsFrom
                lbl_startDeposit.text = "$" + String(selectedAccount.startingDeposit)
                lbl_commission.text = "$" + String(selectedAccount.commission)
                lbl_stepOut.text = selectedAccount.stopOutLevel
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
