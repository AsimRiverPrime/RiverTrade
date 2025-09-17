
//  HyperPayVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 05/05/2025.
//

import UIKit

class HyperPayVC: BaseViewController {
    
    @IBOutlet weak var image_status: UIImageView!
    @IBOutlet weak var lbl_status: UILabel!
    @IBOutlet weak var lbl_amountMessage: UILabel!
    
    var tradeTypeVM = TradeTypeCellVM()
    let status = String()
    var _checkout_id = String()
    var amount = String()
    let odooClientService = OdooClientNew()
    var is_apple = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odooClientService.getTranscationStatus(is_applePay: is_apple, CheckOut_id: _checkout_id) { response in
            print("\n transcation status in hyperPayScreen is: \(response)")
            
            // Parse only what's needed
            if let remoteStatus = response["remote_status"] as? [String: Any],
               let result = remoteStatus["result"] as? [String: Any],
               let resultCode = result["code"] as? String,
               let resultDescription = result["description"] as? String,
               let amount = remoteStatus["amount"] as? String {
                
                self.amount = amount
                
                let transactionStatus = self.getTransactionStatus(from: resultCode)
                print("Status: \(transactionStatus.rawValue), Code: \(resultCode), Desc: \(resultDescription), amount: \(amount)")
                
                DispatchQueue.main.async {
                    self.updateUI(for: transactionStatus)
                    
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar(animated: true)
    }
    
    private func setupNavigationBar(animated: Bool) {
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated,
                                     view: self.view,
                                     vc: self,
                                     VC: AccountsViewController(),
                                     navController: self.navigationController,
                                     title: "Transaction Status",
                                     leftTitle: "",
                                     rightTitle: "",
                                     textColor: .white,
                                     barColor: .black)
    }
    
    func updateUI(for status: TransactionStatus) {
        switch status {
        case .success:
            image_status.image = UIImage(systemName: "checkmark")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            lbl_status.text = "Transaction Success"
            lbl_amountMessage.text = "Your deposit for \(amount) USD has been credited to your account."
           
        case .pending:
            image_status.image = UIImage(systemName: "hourglass.circle")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
            lbl_status.text = "Transaction Pending"
            lbl_amountMessage.text = "Your deposit for \(amount) USD is being processed please wait..."
            
        case .rejected, .timeout, .error:
            image_status.image = UIImage(systemName: "xmark")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            lbl_status.text = "Transaction Failed"
            lbl_amountMessage.text = "Something went wrong. Please try again or contact support."
            
        case .unknown:
            image_status.image = UIImage(systemName: "questionmark")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
            lbl_status.text = "Unknown Status"
            lbl_amountMessage.text = "We couldn't determine the transaction status."
        }
        
//        tradeTypeVM.getBalance(completion: { response in
//            print("get balance in Real deposit: \(response)")
//            if response == "Invalid Response" {
//                return
//            }
//            GlobalVariable.instance.balanceUpdate = response
//            NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
//        })
        
        tradeTypeVM.getUserBalance(completion: { response in
            print("get response of user balance from hyperpayVC: \(response)")
            switch response{
        case .success(let responseModel):
    
            UserManager.shared.currentUser = responseModel.result.user
            
            GlobalVariable.instance.balanceUpdate = "\(responseModel.result.user.balance)"
         
            print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
            NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
         
            case .failure(let error):
                print("Failed to fetch balance: \(error.localizedDescription)")
            }
        })
        
    }
    
    
    func getTransactionStatus(from resultCode: String) -> TransactionStatus {
        let patterns: [(TransactionStatus, [String])] = [
            (.success, [
                #"^(000\.000\.)"#,
                #"^(000\.100\.1)"#,
                #"^(000\.[36])"#,
                #"^(000\.400\.1[12]0)"#
            ]),
            (.pending, [
                #"^(000\.400\.0[^3])"#,
                #"^(000\.400\.100)"#,
                #"^(000\.200\.000)"#
            ]),
            (.rejected, [
                #"^(800\.400\.5)"#,
                #"^(100\.400\.500)"#
            ]),
            (.timeout, [
                #"^(000\.400\.[1][0-9][1-9])"#,
                #"^(000\.400\.2)"#
            ]),
            (.error, [
                #"^(800\.[17]00|800\.800\.[123])"#,
                #"^(900\.[1234]00|000\.400\.030)"#,
                #"^(800\.[56]|999\.|600\.1|800\.800\.[84])"#,
                #"^(100\.39[765])"#,
                #"^(300\.100\.100)"#,
                #"^(100\.400\.[0-3]|100\.380\.100|100\.380\.11|100\.380\.4|100\.380\.5)"#,
                #"^(800\.400\.2|100\.390)"#,
                #"^(800\.[32])"#,
                #"^(800\.1[123456]0)"#,
                #"^(600\.[23]|500\.[12]|800\.121)"#,
                #"^(100\.[13]50)"#,
                #"^(200\.[123]|100\.[53][07]|800\.900|100\.[69]00\.500)"#,
                #"^(100\.800)"#,
                #"^(100\.700|100\.900\.[0-9]{2})"#,
                #"^(100\.100|100\.2[01])"#,
                #"^(100\.55)"#,
                #"^(000\.100\.2)"#,
                #"^(100\.380\.[23]|100\.380\.101)"#
            ])
        ]
        
        for (status, regexList) in patterns {
            for regex in regexList {
                if resultCode.range(of: regex, options: .regularExpression) != nil {
                    return status
                }
            }
        }
        
        return .unknown
    }
    
    
    @IBAction func close_action(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        if let homeVC = navigationController?.viewControllers.first(where: { $0 is HomeTabbarViewController }),
           let walletVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "WalletVC") as? WalletVC {
            
            navigationController?.setViewControllers([homeVC, walletVC], animated: true)
        }
    }

}
enum TransactionStatus: String {
    case success = "Transaction Successful ✅"
    case pending = "Transaction Pending ⏳"
    case rejected = "Transaction Rejected ❌"
    case timeout = "Transaction Timed Out ❌"
    case error = "Transaction Error ❌"
    case unknown = "Transaction Status Unknown 🤔"
}
