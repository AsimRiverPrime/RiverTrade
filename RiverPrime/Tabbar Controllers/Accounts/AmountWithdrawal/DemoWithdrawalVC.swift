//
//  DemoWithdrawalVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/12/2024.
//

import UIKit

class DemoWithdrawalVC: BaseViewController {
    
    @IBOutlet weak var tf_amount: UITextField!
//    {
//        didSet{
//            tf_amount.setIcon(UIImage(systemName: "dollarsign")!)
//          
//            tf_amount.tintColor = UIColor.black
//        }
//    }
    @IBOutlet weak var lbl_withdraw_detail: UILabel!

    
    var odooClient = OdooClientNew()
    var tradeTypeVM = TradeTypeCellVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odooClient.demoWithdrawProtocolDelegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            
            lbl_withdraw_detail.text = "Enter Withdrawal Amount from Demo \(defaultAccount.groupName)/\(defaultAccount.accountNumber)."
        }
        
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Withdraw", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    @IBAction func submit_withdrawAction(_ sender: Any) {
        dismissKeyboard()
        if tf_amount.text != "" {
          
            let balance = Double(GlobalVariable.instance.balanceUpdate)
            print("current balance is: \(balance ?? 0.0)")
            
            if let amount = Double(tf_amount.text ?? ""), let balance = balance, amount <= balance {
                odooClient.demoWithdrawal(amount: (amount))
            } else {
                self.ToastMessage("Please enter less withdrawal amount from current balance")
            }
        }else{
            self.ToastMessage("please enter amount")
        }
    }
}

extension DemoWithdrawalVC: DemoWithdrawProtocol {
    
    func demoWithdrawSuccess(response: [String: Any]) {
        print("the success response: \(response)")
        if let success = response["success"] as? Int {
            if success == 1 {
                tradeTypeVM.getBalance(completion: { response in
                    print("response of get balance for demo withdrawal: \(response)")
                    if response == "Invalid Response" {
                        
                        return
                    }
                    GlobalVariable.instance.balanceUpdate = response
                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
                })
               
            }else{
                self.ToastMessage("Error: Balance not update")
            }
        }else{
            self.ToastMessage("Error: Json is invalid")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func demoWithdrawFailure(error: any Error) {
        self.ToastMessage("Error:\(error)")
    }
    
    
}
