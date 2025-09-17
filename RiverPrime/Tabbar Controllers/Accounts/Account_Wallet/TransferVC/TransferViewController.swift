//
//  TransferViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 19/08/2025.
//

import UIKit
import SVProgressHUD

class TransferViewController: BaseViewController {

    @IBOutlet weak var btn_transfer: CardViewButton!
    @IBOutlet weak var btn_wallet_to_trade: UIButton!
    @IBOutlet weak var btn_trade_to_wallet: UIButton!
    @IBOutlet weak var btn_trade_to_trade: UIButton!
    
    @IBOutlet weak var view_from: UIStackView!
    @IBOutlet weak var lbl_from: UILabel!
    @IBOutlet weak var lbl_to: UILabel!
    
    @IBOutlet weak var lbl_tradeAccount_id: UILabel!
    @IBOutlet weak var lbl_available_balance: UILabel!
    @IBOutlet weak var lbl_wallet_name: UILabel!
    
    
    @IBOutlet weak var btn_from_accountDropDown: CardViewButton!
    @IBOutlet weak var btn_to_accountDropDown: CardViewButton!
    @IBOutlet weak var img_from_trade: UIImageView!
    @IBOutlet weak var img_to_trade: UIImageView!
    @IBOutlet weak var lbl_Mt_Balance: UILabel!
    
    @IBOutlet weak var tf_amount: UITextField!{
        didSet{
            tf_amount.setIcon(UIImage(systemName: "dollarsign") ?? UIImage())
            tf_amount.tintColor = UIColor.systemBlue
        }
    }
    
    @IBOutlet weak var lbl_amountValid: UILabel!
    
    var odooClient = OdooClientNew()
    let getbalanceApi = TradeTypeCellVM()
    
    var wallet_type = String()
    var walletBalance_Name = String()
    var walletBalance = String()
    var mtBalance = String()
   
    var avaliableBalance =  Double()
    var userEmail = String()
    
    var groupName = String()
    var mtAccoutnName = String()
    var accountNumber = String()
   
    var payment_type = String()
    
    var mtAccounts: [MTAccount] = []
    var selectedFromAccount: MTAccount?
    var selectedToAccount: MTAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserData()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if view.frame.origin.y == 0 {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardHeight = keyboardFrame.cgRectValue.height
                view.frame.origin.y -= keyboardHeight / 3   // Adjust this value if needed
            } }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    @IBAction func cancel_action(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func transfer_action(_ sender: Any) {
        dismissKeyboard()
      
        // Validate entered amount
        guard let amountText = tf_amount.text,
              !amountText.isEmpty,
              let amount = Double(amountText)
        else {
            lbl_amountValid.isHidden = false
            lbl_amountValid.text = "Please enter an amount"
            return
        }
        
        if amount < 1 {
            lbl_amountValid.isHidden = false
            lbl_amountValid.text = "The enter amount must be at least 1."
            return
        }else{
            lbl_amountValid.isHidden = true
        }
        
        if payment_type == "wallet" {
            avaliableBalance  = numericValue(from: walletBalance)
            if amount <= avaliableBalance {
                lbl_amountValid.isHidden = true
            } else {
                lbl_amountValid.isHidden = false
                lbl_amountValid.text = "Amount exceeds balance. Enter ≤ $\(avaliableBalance)"
                return
            }
           
            odooClient.transfer_wallet_to_mt(email: userEmail, wallet_type: self.wallet_type, amount: amount, mt_loginId: Int(self.accountNumber) ?? 0, completion: { response in
                print("wallet to mt response: \(response)")
                              
                    if let responseDict = response as? [String: Any],
                       let result = responseDict["result"] as? [String: Any],
                       let message = result["message"] as? String,
                       let success = result["success"] as? Bool {
                        
                        if success {
                            self.ToastMessage(message)
                            self.dismiss(animated: true)
                        }else{
                            
                        }
                    }
                
                // Send notification before dismiss
                   NotificationCenter.default.post(
                       name: Notification.Name("WalletToMTTransferCompleted"),
                       object: nil,
                       userInfo:[:]  // if you want to pass response
                   )
                self.dismiss(animated: true)
            })
        }else if payment_type == "trade" {
            avaliableBalance = Double(mtBalance) ?? 0
            
            odooClient.transfer_mt_to_wallet(email: userEmail, amount: amount, mt_loginId: Int(self.accountNumber) ?? 0, completion: { response in
                print("Mt to wallet response: \(response)")
                // Send notification before dismiss
                   NotificationCenter.default.post(
                       name: Notification.Name("WalletToMTTransferCompleted"),
                       object: nil,
                       userInfo:[:] //["response": response]  // if you want to pass response
                   )
                
                self.dismiss(animated: true)
            })
        }else{
            if amount <= avaliableBalance {
                lbl_amountValid.isHidden = true
            } else {
                lbl_amountValid.isHidden = false
                lbl_amountValid.text = "Amount exceeds balance. Enter ≤ $\(avaliableBalance)"
                return
            }
            if let fromAcc = selectedFromAccount,
               let toAcc = selectedToAccount {
                
                odooClient.transfer_mt_to_mt(amount: amount, fromAccountNumber: Int(fromAcc.accountNumber) ?? 0,fromPassword: fromAcc.password,toAccountNumber: Int(toAcc.accountNumber) ?? 0, toPassword: toAcc.password ) { response in
                    
                    // Cast response to dictionary
                    if let responseDict = response as? [String: Any],
                       let result = responseDict["result"] as? [String: Any],
                       let success = result["success"] as? Int {
                  
                            if success == 1 {
                                NotificationCenter.default.post(name: Notification.Name("WalletToMTTransferCompleted"),object: nil,userInfo: [:])
                                self.ToastMessage("Transfer successfully done.")
                                let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                               
                                    self?.dismiss(animated: true)
                                }
                            } else {
                                // Optional: extract error message if available
                                let errorMessage = result["error"] as? String ?? "Transfer cannot be done."
                                self.ToastMessage(errorMessage)
                            }
                        } else {
                            // Response is not a dictionary
                            self.ToastMessage("Invalid server response.")
                        }
                    }
                }
            }
        
    }
    
    @IBAction func wallet_to_trade_action(_ sender: Any) {
        payment_type = "wallet"
        updateTypeButtons(for: "wallet")
    }
    
    @IBAction func trade_to_wallet_action(_ sender: Any) {
        payment_type = "trade"
        updateTypeButtons(for: "trade")
    }
    
    @IBAction func trade_to_trade_action(_ sender: Any) {
        payment_type = "MT_transfer"
        updateTypeButtons(for: "MT_transfer")
    }
    
    @IBAction func fromTrade_action(_ sender: UIButton) {
        btn_to_accountDropDown.setTitle("Select To Trade Account", for: .normal)
        self.selectedToAccount = nil
        btn_to_accountDropDown.setTitleColor(.white, for: .normal)
        updateSubmitButtonState()
        
        let dropdownItems = mtAccounts.map { acc in
            let icon = acc.isReal ? "Real:" : "Demo:"//"🟢" : "🔴"
            return "\(icon) \(acc.name) - \(acc.accountNumber)"
        }
        
        self.dynamicDropDownButton(sender, list: dropdownItems) { [weak self] index, item in
            guard let _ = self else { return }
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            let selectedAcc = self?.mtAccounts[index]   // ✅ get actual account
            self?.selectedFromAccount = selectedAcc     // ✅ save it
            print("Selected account from = \(selectedAcc)")
          
            self?.getbalanceApi.getUserBalance(login_id: Int(selectedAcc?.accountNumber ?? "0"), mtPassword: selectedAcc?.password, _isDemo: selectedAcc?.isReal, completion: {  result in
                switch result {
                case .success(let responseModel):
                    
                    // Save the response model or use it as needed
                    print("MT account Balance for dropdown selected account: \(responseModel.result.user.balance)")
                    self?.lbl_Mt_Balance.text = "Available Balance: $\(responseModel.result.user.balance)"
                    self?.avaliableBalance = responseModel.result.user.balance
                    
                case .failure(let error):
                    print("get Mt balance error in transferVC: \(error)")
                }
            })
            sender.setTitle(item, for: .normal)
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            sender.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBAction func toTrade_action(_ sender: UIButton) {
        guard let fromAcc = selectedFromAccount else {
            print("⚠️ No from-account selected yet")
            self.ToastMessage("⚠️ No from account selected yet")
            return
        }
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        sender.setTitleColor(.white, for: .normal)
        // Filter only matching type but exclude the selected "from" account
        let filteredAccounts = mtAccounts.filter {
            $0.isReal == fromAcc.isReal && $0.accountNumber != fromAcc.accountNumber
        }

        if filteredAccounts.isEmpty {
            self.ToastMessage("⚠️ No other account found of same type")
            self.tf_amount.isEnabled = false
            self.tf_amount.layer.borderColor = UIColor.systemRed.cgColor
            return
        }else{
            self.tf_amount.isEnabled = true
            self.tf_amount.layer.borderColor = UIColor.gray.cgColor
        }
        
        let dropdownItems = filteredAccounts.map { acc in
            let icon = acc.isReal ? "Real:" : "Demo:"
            return "\(icon) \(acc.name) - \(acc.accountNumber)"
        }
        
        self.dynamicDropDownButton(sender, list: dropdownItems) { [weak self] index, item in
            guard let _ = self else { return }
            
            let selectedAcc = filteredAccounts[index]
            print("Selected to = \(selectedAcc)")
            self?.selectedToAccount = selectedAcc
            
            sender.setTitle(item, for: .normal)
            self?.updateSubmitButtonState()
        }
       
    }
    
    func updateSubmitButtonState() {
        let isEnabled = (selectedFromAccount != nil && selectedToAccount != nil)
        btn_transfer.isEnabled = isEnabled
        btn_transfer.alpha = isEnabled ? 1.0 : 0.5 // dim when disabled
    }
    
    func updateTypeButtons(for type: String) {
      
        if type == "wallet" {
            self.tf_amount.isEnabled = true
            btn_transfer.isEnabled = true
            btn_transfer.alpha = 1.0
            
           
            
            btn_wallet_to_trade.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            btn_trade_to_wallet.setImage(UIImage(systemName: "circle"), for: .normal)
            btn_trade_to_trade.setImage(UIImage(systemName: "circle"), for: .normal)
//            btn_transfer.setTitle("TRANSFER TO TRADE", for: .normal)
//            btn_transfer.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)

            btn_wallet_to_trade.backgroundColor = .darkGray
            btn_trade_to_wallet.backgroundColor = .clear
            btn_trade_to_trade.backgroundColor = .clear
            
            view_from.isHidden = false
            lbl_wallet_name.isHidden = false
            lbl_tradeAccount_id.isHidden = false
            btn_from_accountDropDown.isHidden = true
            btn_to_accountDropDown.isHidden = true
            lbl_Mt_Balance.isHidden = true
            img_from_trade.isHidden = true
            img_to_trade.isHidden = true
            
            // from labels
            lbl_from.text = "From Wallet"
            lbl_tradeAccount_id.text = walletBalance_Name
            lbl_available_balance.text = "Available Balance: \(self.walletBalance)"
            // to labels
            lbl_to.text = "To Trade Account"
            lbl_wallet_name.text = "\(self.mtAccoutnName) " + "(\(self.groupName)-\(accountNumber))" + "\t $\(self.mtBalance)"
            
        }else if type == "trade" {
            self.tf_amount.isEnabled = true
            btn_transfer.isEnabled = true
            btn_transfer.alpha = 1.0
            
            btn_trade_to_wallet.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            btn_wallet_to_trade.setImage(UIImage(systemName: "circle"), for: .normal)
            btn_trade_to_trade.setImage(UIImage(systemName: "circle"), for: .normal)
//            btn_transfer.setTitle("TRANSFER TO WALLET", for: .normal)
//            btn_transfer.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

            btn_wallet_to_trade.backgroundColor = .clear
            btn_trade_to_trade.backgroundColor = .clear
            btn_trade_to_wallet.backgroundColor = .darkGray
            
            view_from.isHidden = false
            lbl_wallet_name.isHidden = false
            lbl_tradeAccount_id.isHidden = false
            btn_from_accountDropDown.isHidden = true
            btn_to_accountDropDown.isHidden = true
            lbl_Mt_Balance.isHidden = true
            img_from_trade.isHidden = true
            img_to_trade.isHidden = true
            
            // from labels
            lbl_from.text = "From Trade Account"
            lbl_tradeAccount_id.text = "\(self.mtAccoutnName) " + "(\(self.groupName)-\(accountNumber))" + "\t $\(self.mtBalance)"
            lbl_available_balance.text = "Available Balance: $\(self.mtBalance)"
            // to labels
            lbl_to.text = "To Wallet"
            lbl_wallet_name.text = walletBalance_Name
                        
        }else{
            
            btn_trade_to_trade.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            btn_wallet_to_trade.setImage(UIImage(systemName: "circle"), for: .normal)
            btn_trade_to_wallet.setImage(UIImage(systemName: "circle"), for: .normal)
 
            btn_trade_to_wallet.backgroundColor = .clear
            btn_wallet_to_trade.backgroundColor = .clear
            btn_trade_to_trade.backgroundColor = .darkGray
            
            view_from.isHidden = true
            lbl_wallet_name.isHidden = true
            lbl_tradeAccount_id.isHidden = true
            btn_from_accountDropDown.isHidden = false
            btn_to_accountDropDown.isHidden = false
            lbl_Mt_Balance.isHidden = false
            img_from_trade.isHidden = false
            img_to_trade.isHidden = false
            
            // from labels
            lbl_from.text = "From Trade Account"
           
            lbl_Mt_Balance.text = "Available Balance: $\(self.mtBalance)"
            // to labels
            lbl_to.text = "To Trade Account"
            
        }
       
    }
    
}
extension TransferViewController {
    func numericValue(from balanceString: String) -> Double {
        let cleaned = balanceString.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return Double(cleaned) ?? 0.0
    }
    
    func getUserData() {
        SVProgressHUD.show()
        getbalanceApi.getUserBalance { result in
            switch result {
            case .success(let responseModel):
                
                // Save the response model or use it as needed
                print("MT account Balance get: \(responseModel.result.user.balance)")
                self.mtBalance = "\(responseModel.result.user.balance)"
                self.payment_type = "wallet"
                self.updateTypeButtons(for: "wallet")
                SVProgressHUD.dismiss()
            case .failure(let error):
                print("Failed to fetch balance: \(error.localizedDescription)")
            }
        }
        
        guard let savedList = UserDefaults.standard.dictionary(forKey: "userAccountsData") as? [String: [String: Any]] else {
            return
        }
        print("All MT accounts in transfer VC: \(savedList)")
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            print("\n Default Account User get in transfer VC: \(defaultAccount)")
            self.accountNumber = "\(defaultAccount.accountNumber)"
            self.groupName = defaultAccount.groupName
            self.mtAccoutnName = defaultAccount.name
            
            if defaultAccount.isReal {
                self.wallet_type = "real"
            }else{
                self.wallet_type = "demo"
            }
        }
        
        self.mtAccounts = savedList.values.compactMap { dict in
            guard
                let accountNumber = dict["accountNumber"] as? Int,
                let name = dict["name"] as? String,
                let password = dict["password"] as? String,
                let isReal = dict["isReal"] as? Int,
                let isDefault = dict["isDefault"] as? Int
                
            else { return nil }
            
            return MTAccount(
                accountNumber: "\(accountNumber)",
                name: name,
                isReal: isReal == 1,
                isDefault: isDefault == 1,
                password: password
            )
        }
    }
}
struct MTAccount {
    let accountNumber: String
    let name: String
    let isReal: Bool
    let isDefault: Bool
    let password: String
}
