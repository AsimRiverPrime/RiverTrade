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
    
    weak var delegate: AccountInfoDelegate?
    var accountInfo: AccountInfo = .deposit
    var navigation: NavigationType = .account
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setHeaderUI(_ navigation: NavigationType) {
        let heightOfSuperview = self.bounds.height
        

        switch navigation {
            
        case .deposit:
            viewOfAccount.isHidden =  true
            headerTitle.text = "Deposit"
            labelStack.isHidden = true
            viewOfBtnStack.isHidden = true
            secondTitle.text = "Verification required"
//            heightOfAccountHeaderView.constant = 1.0
            heightOfAccountHeaderView.constant = heightOfSuperview * 1.0 // this has the same effect as multiplier
            
        case .account:
            viewOfAccount.isHidden =  false
            headerTitle.text = "Account"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = false
            secondTitle.text = "#0123456"
            
        case .withdraw:
            viewOfAccount.isHidden =  true
            headerTitle.text = "Withdraw"
            labelStack.isHidden = true
            viewOfBtnStack.isHidden = true
            secondTitle.text = "All payment methods"
            heightOfAccountHeaderView.constant = heightOfSuperview * 1.0
            
        case .trade:
            viewOfAccount.isHidden =  true
            headerTitle.text = "Trade"
            labelStack.isHidden = false
            viewOfBtnStack.isHidden = false
            
            secondTitle.text = "#0123456"
        case .market:
            break
        case .result:
            break
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
