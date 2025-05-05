//
//  DemoDepositVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/12/2024.
//

import UIKit

class DemoDepositVC: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var tf_amount: UITextField!
    @IBOutlet weak var lbl_deposit_detail: UILabel!
    @IBOutlet weak var lbl_exceededAmount: UILabel!
    @IBOutlet weak var btn_submit: CardViewButton!
    
    var ammountValue = String()
    let maxAmount = 1_000_000.0 // Maximum limit (1 million)
    var isRealAcount = false
    
    var odooClient = OdooClientNew()
    var tradeTypeVM = TradeTypeCellVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odooClient.demoDepositProtocolDelegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
//            //print("\n Default Account User: \(defaultAccount)")
            isRealAcount = defaultAccount.isReal
            if defaultAccount.isReal {
                lbl_deposit_detail.text = "Enter the amount you wish to deposit into your Real Trading account.(\(defaultAccount.groupName)/ #\(defaultAccount.accountNumber))."
            }else{
                lbl_deposit_detail.text = "Enter the amount you wish to deposit into your Demo Trading account.(\(defaultAccount.groupName)/ #\(defaultAccount.accountNumber))."
            }
        }
        
        tf_amount.delegate = self
        tf_amount.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
           
           @objc func textFieldDidChange() {
               validateDepositAmount()
           }

    func validateDepositAmount() {
        guard let text = tf_amount.text, let enteredAmount = Double(text) else {
            return
        }
//       let currentAmmount =  (Double(ammountValue) ?? 0.0)
        let cleanedAmountValue = ammountValue.replacingOccurrences(of: ",", with: "") // "11676.33"
        let currentAmount = Double(cleanedAmountValue) ?? 0.0
        
        
        if enteredAmount > maxAmount {
            self.ToastMessage("You cannot deposit more than $1,000,000.")
            tf_amount.text = ""
            lbl_exceededAmount.textColor = .systemRed
           
        } else if (currentAmount + enteredAmount) > maxAmount {
            self.ToastMessage("Total balance after deposit cannot be exceed $1,000,000.")
            tf_amount.text = ""
            lbl_exceededAmount.textColor = .systemRed
           
        }else{
            lbl_exceededAmount.textColor = .white
           
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
            if isRealAcount{
                let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
                // vc.delegateCompeleteProfile = self
                self.navigate(to: vc) //  PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            }else{
                odooClient.demoDeposit(amount: Double(tf_amount.text ?? "") ?? 0)
            }
        }else{
            self.ToastMessage("Please enter amount")
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
//                dismiss(animated: true)
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
