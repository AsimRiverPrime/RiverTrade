//
//  DemoWithdrawalVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/12/2024.
//

import UIKit

class DemoWithdrawalVC: BaseViewController {
    
    @IBOutlet weak var tf_amount: UITextField!
  
    @IBOutlet weak var lbl_withdraw_detail: UILabel!
    @IBOutlet weak var lbl_errorMessage: UILabel!
    @IBOutlet weak var btn_submit: CardViewButton!
    
    var isRealAcount = Bool()
    var odooClient = OdooClientNew()
    var tradeTypeVM = TradeTypeCellVM()
    var selectedPaymentTypeId = Int()
    var selectedPaymentTypeName = String()
    
    var request_type = String()
    var walletBalance = String()
    var wallet_Name = String()
    
    let maxAmount = 1_000_000.0 // Maximum limit (1 million) for real deposit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odooClient.demoWithdrawProtocolDelegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            
//             \(defaultAccount.groupName)/\(defaultAccount.accountNumber)."
        }
        if request_type == "Withdrawal" {
            lbl_withdraw_detail.text = "Enter the amount you want to withdrawal from  \(wallet_Name)"
        }else{
            lbl_withdraw_detail.text = "Enter the amount you want deposit to  \(wallet_Name)"
        }
//        print("Stack:", navigationController?.viewControllers)
        tf_amount.delegate = self
        tf_amount.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Enter \(request_type) Amount", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    @IBAction func submit_withdrawAction(_ sender: Any) {
        dismissKeyboard()
        
        if tf_amount.text != "" {
            let x = tf_amount.text ?? ""
            let cleanedAmountValue = x.replacingOccurrences(of: ",", with: "")
            let currentAmount = Double(cleanedAmountValue) ?? 0.0
            
          
                print("current wallet balance is: \(walletBalance)")
                let cleanString = walletBalance.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)

                // Convert to Double
                guard let newBalance = Double(cleanString) else {
                    print("❌ Invalid number")
                    return
                }
            
            if request_type == "Withdrawal"{
                
                if currentAmount <= newBalance {
                    self.lbl_errorMessage.isHidden = true
                    
                    odooClient.create_withdrawal_fundRequest(amount: currentAmount, MethodTypeId: selectedPaymentTypeId, paymentType: "withdrawal")
                } else {
                    self.lbl_errorMessage.isHidden = false
                    self.lbl_errorMessage.text  = "Please enter less withdrawal amount from your current balance"
                }
            }else{
               
//                if ["Credit Card", "Credit Card (Default)"].contains(selectedPaymentTypeName) {
                    if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DepositViewController") as? DepositViewController {
//                    vc.ammountValue = tf_amount.text ?? ""
                    vc.ammountValue = (tf_amount.text ?? "").replacingOccurrences(of: ",", with: "")
                    self.navigate(to: vc)
                }
//                }else{
//                    odooClient.create_withdrawal_fundRequest(amount: currentAmount, MethodTypeId: selectedPaymentTypeId, paymentType: "deposit")
//                }
        }
            
        }else{
            self.lbl_errorMessage.isHidden = false
            self.lbl_errorMessage.text = "please enter amount"
        }
    }
    
    func validateDepositAmount() {
        
        guard let text = tf_amount.text else { return }
        
        // Remove commas for validation
        let cleanedText = text.replacingOccurrences(of: ",", with: "")
        guard let enteredAmount = Double(cleanedText) else { return }
        
        let cleanedAmountValue = walletBalance.replacingOccurrences(of: ",", with: "") // "11676.33"
        let currentAmount = Double(cleanedAmountValue) ?? 0.0
        
        if enteredAmount > maxAmount {
            self.lbl_errorMessage.isHidden = false
            self.ToastMessage("You cannot deposit more than $1,000,000.")
            self.lbl_errorMessage.text = "You cannot deposit more than $1,000,000."
            tf_amount.text = ""
            lbl_errorMessage.textColor = .systemRed
            btn_submit.isUserInteractionEnabled = false
        } else if (currentAmount + enteredAmount) > maxAmount {
            self.lbl_errorMessage.isHidden = false
            self.lbl_errorMessage.text = "Total balance after deposit cannot be exceed $1,000,000."
            self.ToastMessage("Total balance after deposit cannot be exceed $1,000,000.")
            tf_amount.text = ""
            lbl_errorMessage.textColor = .systemRed
            btn_submit.isUserInteractionEnabled = false
        }else{
            lbl_errorMessage.isHidden = true
            btn_submit.isUserInteractionEnabled = true
        }
    }
    
}

extension DemoWithdrawalVC: DemoWithdrawProtocol {
    
    func demoWithdrawSuccess(response: [String: Any]) {
        print("the success response: \(response)")
        if let success = response["success"] as? Int {
            if success == 1 {
                self.lbl_errorMessage.isHidden = true
                
                let message = response["message"] as? String

                self.ToastMessage(message ?? "")
         
                if let homeVC = navigationController?.viewControllers.first(where: { $0 is HomeTabbarViewController }),
                   let walletVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "WalletVC") as? WalletVC {
                    
                    navigationController?.setViewControllers([homeVC, walletVC], animated: true)
                }
                
            }else{
                self.ToastMessage("Error: Balance not update")
            }
        }else{
            self.ToastMessage("Server Error")
        }
       
    }
    
    func demoWithdrawFailure(error: String) {
      self.ToastMessage( "Error:\(error)")
        self.lbl_errorMessage.isHidden = false
        self.lbl_errorMessage.text = "\(error)"
    }
    
    
}

extension DemoWithdrawalVC: UITextFieldDelegate {
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        if let text = textField.text {
            // Format number with commas
            let formatted = String.formatStringNumberTF(text)
            textField.text = formatted
        }
        
        if request_type == "Deposit" {
            validateDepositAmount()
        }
    }
    
}
