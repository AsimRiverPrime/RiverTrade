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
    var userBalance = Double()
    
    public override func awakeFromNib() {
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            print("\n Default Account user in fundsView : \(defaultAccount)")
            self.lbl_loginID.text = "#\(defaultAccount.accountNumber)"
            lbl_acctType.text = defaultAccount.isReal == true ? "Real" : "Demo"
            self.lbl_acctGroup.text = defaultAccount.groupName
            self.userGroupID = defaultAccount.groupID
        }
        
        self.fireStoreInstance.fetchAccountsGroup { [weak self] fetchedAccounts in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                print("\n fetchedAccounts Groups: \(fetchedAccounts)")
                
                self.accountsGroup = fetchedAccounts
                
                if let selectedAccount = fetchedAccounts.first(where: { $0.id == self.userGroupID }) {
                    self.lbl_leverage.text = selectedAccount.leverage
                    self.lbl_spreadFrom.text = selectedAccount.spreadsFrom
                    self.lbl_startDeposit.text = "$\(selectedAccount.startingDeposit)"
                    self.lbl_commission.text = "$\(selectedAccount.commission)"
                    self.lbl_stepOut.text = selectedAccount.stopOutLevel
                }
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil {
            // View is visible again, update UI
            if userBalance == 0 {
                userBalance = Double(GlobalVariable.instance.balanceUpdate) ?? 0.0
            }
            
            updateUserFields()
        }
    }
    
    @objc func notificationPopup(_ notification: NSNotification) {
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received amount in Funds: \(ammount)")
            // Save last value for reuse
               self.userBalance = Double(ammount) ?? 0.0
               
               // Update immediately
               updateUserFields()
            
        }
    }
        
    func updateUserFields() {
        if let user = UserManager.shared.currentUser {
    
            self.lbl_balance.text = "$\(String.formatStringNumber(String(user.balance)))"
    
            self.lbl_equity.text = "$\(String.formatStringNumber(String(self.userBalance)))" //"$\(ammount)"
            let totalPL = userBalance - (user.balance) //(Double(ammount) ?? 0.0) - (user.balance)
            let freeMargin = userBalance - (user.margin) //(Double(ammount) ?? 0.0) - (user.margin)
            self.lbl_freeMargin.text = "$\(String.formatStringNumber(String(freeMargin)))" //"$"+"\(freeMargin)".trimmedTrailingZeros()
            self.lbl_totalPL.text = "$\(String.formatStringNumber(String(totalPL)))" //"$"+"\(totalPL)".trimmedTrailingZeros()
    
            self.lbl_totalDeposit.text = "$\(String.formatStringNumber(String(user.totalDeposit)))"
    
            self.lbl_totalWithdrawal.text = "$\(String.formatStringNumber(String(user.totalWithdraw)))"
    
            self.lbl_Margin.text = "$\(user.margin)"
    
    
            if user.margin == 0.0 {
                self.lbl_marginLevel.text = "0%"
            }else{
                let marginLevel = userBalance / (user.margin) * 100 // (Double(ammount) ?? 0.0) / (user.margin) * 100
                let marginLevelValue = "\(marginLevel)".trimmedTrailingZeros()
                self.lbl_marginLevel.text = marginLevelValue + "%"
            }
            print("\n user balance values in detail(funds): \(user)")
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
        
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
}

