//
//  AccountTableViewCell.swift
//  RiverPrime
//
//  Created by Ahmad on 13/07/2024.
//

import UIKit

enum AccountInfo {
    case deposit
    case withDraw
    case history
    case detail
    case createAccount
    case notification
}

enum NavigationType{
    case account
    case trade
    case market
    case result
    case history
    case deposit
    case withdraw
    case detail
    case notification
}
protocol AccountInfoDelegate: AnyObject {
    func accountInfoTap(_ accountInfo: AccountInfo)
    
}

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var outer_view: UIView!
//    @IBOutlet weak var height_outerView: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var secondTitle: UILabel!
    @IBOutlet weak var labelAmmount: UILabel!
    @IBOutlet weak var labelStack: UIStackView!
    @IBOutlet weak var viewOfAccount: UIStackView!
    @IBOutlet weak var viewOfBtnStack: UIView!
      
    @IBOutlet weak var lbl_account: UILabel!
    @IBOutlet weak var lbl_MT5: UILabel!
    @IBOutlet weak var lbl_accountType: UILabel!
    
    @IBOutlet weak var heightOfAccountHeaderView: NSLayoutConstraint!
    @IBOutlet weak var widthOfMainStackView: NSLayoutConstraint!
    
    @IBOutlet weak var height_ViewBtnStack: NSLayoutConstraint!
    @IBOutlet weak var Btn_view: UIView!
    @IBOutlet weak var btn_funds: UIButton!
    @IBOutlet weak var btnFundsLineView: UIView!
//    @IBOutlet weak var height_BtnView: NSLayoutConstraint!
    
    @IBOutlet weak var btn_Settings: UIButton!
    @IBOutlet weak var btnSettingsLineView: UIView!
    
    weak var delegate: AccountInfoDelegate?
   
    var accountInfo: AccountInfo = .deposit
    var navigation: NavigationType = .account
    
    var login_Id = Int()
    var account_type = String()
    var account_group = String()
    var mt5 = String()
    
    var get_balance = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.outer_view.layoutIfNeeded()
        labelAmmount.text = "\(GlobalVariable.instance.balanceUpdate) USD"
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.BalanceUpdate(_:)), name: .BalanceUpdate, object: nil)
        
//        //NotificationObserver.shared.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
        
        //MARK: - width constraint of main stack view.
        if UIDevice.isPhone {
//            viewOfAccount.spacing = 2
            widthOfMainStackView.constant = 0
        } else {
//            viewOfAccount.spacing = -300
            widthOfMainStackView.constant = -300
        }
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let loginID = savedUserData["loginId"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool, let accountType = savedUserData["demoAccountGroup"] as? String, let isRealAccount = savedUserData["realAccountCreated"] as? Bool  {
               
                self.login_Id = loginID
                
                if isCreateDemoAccount == true {
                    self.account_type = " Demo "
                    mt5 = " MT5 "
                    self.account_group = " \(accountType) "
                }
                if isRealAccount == true {
                    self.account_type = " Real "
                    mt5 = " MT5 "
                    self.account_group = " \(accountType) "
                }
                
                
                if accountType == "Pro Account" {
                    self.account_group = " PRO "
                    mt5 = " MT5 "
                }else if accountType == "Prime Account" {
                    self.account_group = " PRIME "
                    mt5 = " MT5 "
                }else if accountType == "Premium Account" {
                    self.account_group = " PREMIUM "
                    mt5 = " MT5 "
                }else{
//                    self.account_group = ""
//                    mt5 = ""
                    
                }
            }
        }
    }
    
    @objc func notificationPopup(_ notification: NSNotification) {
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received ammount: \(ammount)")
            self.labelAmmount.text = "\(ammount) USD"
        }
        
    }
    
    @objc private func BalanceUpdate(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo["BalanceUpdateType"] as? String {
            print("Received string: \(receivedString)")
            self.labelAmmount.text = "\(receivedString) USD"
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setHeaderUI(_ navigation: NavigationType) {
        let heightOfSuperview = self.bounds.height
        
        switch navigation {
            
        case .deposit:
            Btn_view.isHidden = true
            viewOfAccount.isHidden =  true
            headerTitle.text = "Deposit"
            labelStack.isHidden = true
            viewOfBtnStack.isHidden = true
            
            secondTitle.text = "Verification required"
//            heightOfAccountHeaderView.constant = 1.0
            heightOfAccountHeaderView.constant = heightOfSuperview * 1.0 // this has the same effect as multiplier
            
        case .account:
            Btn_view.isHidden = true
            viewOfAccount.isHidden =  false
            headerTitle.text = "Account"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = false
//            height_ViewBtnStack.constant = 114 
            secondTitle.text = "#\(self.login_Id)"
            lbl_MT5.text = mt5
            lbl_account.text = self.account_type
            lbl_accountType.text = self.account_group
            
        case .withdraw:
            Btn_view.isHidden = true
            viewOfAccount.isHidden =  true
            headerTitle.text = "Withdraw"
            labelStack.isHidden = true
            viewOfBtnStack.isHidden = true
            secondTitle.text = "All payment methods"
            heightOfAccountHeaderView.constant = heightOfSuperview * 1.0
         
        case .detail:
            Btn_view.isHidden = false
            viewOfAccount.isHidden =  true
            headerTitle.text = "Details"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = true
            secondTitle.text = "#\(self.login_Id)"
            
        case .trade:
            Btn_view.isHidden = true
//            height_outerView.constant = 210//headerView.bounds.height
//            height_BtnView.constant = 0
            outer_view.backgroundColor = UIColor(named: "splashScreen")
            viewOfAccount.isHidden =  true
            headerTitle.text = "Trade"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = true
//            height_ViewBtnStack.constant = 0
            secondTitle.text = "#\(self.login_Id)"
            lbl_MT5.text = mt5
            lbl_account.text = self.account_type
            lbl_accountType.text = self.account_group
            
        case .market:
            Btn_view.isHidden = true
            viewOfAccount.isHidden =  true
            headerTitle.text = "Market"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = false
            secondTitle.text = "#\(self.login_Id)"
            
        case .result:
            Btn_view.isHidden = false
            viewOfAccount.isHidden =  true
            headerTitle.text = "Details"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = true
            secondTitle.text = "#\(self.login_Id)"
        
        case .history:
            break
        case .notification:
            break
        }
        
    }
    
    @IBAction func depositBtnAction(_ sender: Any) {
        delegate?.accountInfoTap(.deposit)
    }
    @IBAction func withDrawBtnAction(_ sender: Any) {
        delegate?.accountInfoTap(.withDraw)
    }

    @IBAction func historyBtnAction(_ sender: Any) {
        delegate?.accountInfoTap(.history)
    }

    @IBAction func detailBtnAction(_ sender: Any) {
        delegate?.accountInfoTap(.detail)
    }
    @IBAction func notificationBtnAction(_ sender: Any) {
        delegate?.accountInfoTap(.notification)
    }
    
    @IBAction func createAcoountBtnAction(_ sender: Any) {
        delegate?.accountInfoTap(.createAccount)
    }
    
}
