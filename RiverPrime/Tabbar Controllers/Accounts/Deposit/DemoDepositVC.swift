//
//  DemoDepositVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/12/2024.
//

import UIKit

class DemoDepositVC: BaseViewController {

    @IBOutlet weak var tf_amount: UITextField!
    @IBOutlet weak var lbl_deposit_detail: UILabel!
    
    var odooClient = OdooClientNew()
    var tradeTypeVM = TradeTypeCellVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odooClient.demoDepositProtocolDelegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
//            //print("\n Default Account User: \(defaultAccount)")
            
            lbl_deposit_detail.text = "Enter Deposit Amount for Demo \(defaultAccount.groupName)/\(defaultAccount.accountNumber)."
        }
        
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar

        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Deposit", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    @IBAction func submit_action(_ sender: Any) {
        dismissKeyboard()
        if tf_amount.text != "" {
            odooClient.demoDeposit(amount: Double(tf_amount.text ?? "") ?? 0)
        }else{
            self.ToastMessage("please enter amount")
        }
    }
    
}

extension DemoDepositVC: DemoDepositProtocol {
    func demoDepositSuccess(response: [String: Any]) {
        print("the success response: \(response)")
        if let success = response["success"] as? Int {
            if success == 1 {
                tradeTypeVM.getBalance(completion: { response in
                    print("response of get balance in demo deposit: \(response)")
                    if response == "Invalid Response" {
                        
                        return
                    }
                    GlobalVariable.instance.balanceUpdate = response
                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
                })
                dismiss(animated: true)
            }else{
                self.ToastMessage("Error: Balance not update")
            }
        }else{
            self.ToastMessage("Error: Json is invalid")
            }
        self.navigationController?.popViewController(animated: true)
}
    
    func demoDepositFailure(error: any Error) {
        self.ToastMessage("Error:\(error)")
    }
    
    
}
