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
        
        tf_amount.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        if let text = textField.text {
            // Format number with commas
            let formatted = String.formatStringNumberTF(text)
            textField.text = formatted
        }
        
        // Validate after formatting
        validateDepositAmount()
    }
    
    func validateDepositAmount() {
        guard let text = tf_amount.text else { return }
        
        // Remove commas for validation
        let cleanedText = text.replacingOccurrences(of: ",", with: "")
        guard let enteredAmount = Double(cleanedText) else { return }
        
        let cleanedAmountValue = ammountValue.replacingOccurrences(of: ",", with: "")
        let currentAmount = Double(cleanedAmountValue) ?? 0.0
        
        if enteredAmount > maxAmount {
            self.ToastMessage("You cannot deposit more than $1,000,000.")
            tf_amount.text = ""
            lbl_exceededAmount.textColor = .systemRed
        } else if (currentAmount + enteredAmount) > maxAmount {
            self.ToastMessage("Total balance after deposit cannot exceed $1,000,000.")
            tf_amount.text = ""
            lbl_exceededAmount.textColor = .systemRed
        } else {
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
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Demo Account Deposit", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    @IBAction func submit_action(_ sender: Any) {
        dismissKeyboard()
        
        if tf_amount.text != ""  {
            
            let x = tf_amount.text ?? ""
            let cleanedAmountValue = x.replacingOccurrences(of: ",", with: "")
            let currentAmount = Double(cleanedAmountValue) ?? 0.0
            
            if currentAmount < 1 {
                self.ToastMessage("Deposit amount must be at least $1.")
                tf_amount.text = ""
                lbl_exceededAmount.textColor = .systemRed
                return
            }
            
            odooClient.demoDeposit(amount: currentAmount)
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
                
                tradeTypeVM.getUserBalance(completion: { response in
                    print("get response of user balance for demo deposit: \(response)")
                    switch response{
                    case .success(let responseModel):
                        self.ToastMessage("Deposit done successfully")
                        
                        UserManager.shared.currentUser = responseModel.result.user
                        
                        GlobalVariable.instance.balanceUpdate = "\(responseModel.result.user.balance)"
                        
                        print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
                        
                    case .failure(let error):
                        print("Failed to fetch balance: \(error.localizedDescription)")
                    }
                })
                
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
