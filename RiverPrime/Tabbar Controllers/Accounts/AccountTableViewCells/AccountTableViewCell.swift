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

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var secondTitle: UILabel!
    @IBOutlet weak var labelAmmount: UILabel!
    @IBOutlet weak var labelStack: UIStackView!
    @IBOutlet weak var viewOfAccount: UIStackView!
    @IBOutlet weak var viewOfBtnStack: UIView!
        
    @IBOutlet weak var heightOfAccountHeaderView: NSLayoutConstraint!
    @IBOutlet weak var widthOfMainStackView: NSLayoutConstraint!
    
    @IBOutlet weak var Btn_view: UIView!
    @IBOutlet weak var btn_funds: UIButton!
    @IBOutlet weak var btnFundsLineView: UIView!
    
    @IBOutlet weak var btn_Settings: UIButton!
    @IBOutlet weak var btnSettingsLineView: UIView!
    
    weak var delegate: AccountInfoDelegate?
   
    var accountInfo: AccountInfo = .deposit
    var navigation: NavigationType = .account
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //MARK: - width constraint of main stack view.
        if UIDevice.isPhone {
//            viewOfAccount.spacing = 2
            widthOfMainStackView.constant = 0
        } else {
//            viewOfAccount.spacing = -300
            widthOfMainStackView.constant = -300
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
            secondTitle.text = "#0123456"
            
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
            secondTitle.text = "#0123456"
            
        case .trade:
            Btn_view.isHidden = true
            viewOfAccount.isHidden =  true
            headerTitle.text = "Trade"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = false
            secondTitle.text = "#0123456"
            
        case .market:
            Btn_view.isHidden = true
            viewOfAccount.isHidden =  true
            headerTitle.text = "Market"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = false
            secondTitle.text = "#0123456"
            
        case .result:
            Btn_view.isHidden = false
            viewOfAccount.isHidden =  true
            headerTitle.text = "Details"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = true
            secondTitle.text = "#0123456"
        
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

    
}
