//
//  CreateAccountTVCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/08/2024.
//

import UIKit

enum CreateAccountInfo {
    case createNew
    case unarchive
    case notification
}

protocol CreateAccountInfoDelegate: AnyObject {
    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo)
}

class CreateAccountTVCell: UITableViewCell {

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var secondTitle: UILabel!
    @IBOutlet weak var viewOfAccount: UIStackView!
    @IBOutlet weak var viewOfBtnStack: UIView!
        
    @IBOutlet weak var heightOfAccountHeaderView: NSLayoutConstraint!
    @IBOutlet weak var widthOfMainStackView: NSLayoutConstraint!
    
    weak var delegate: CreateAccountInfoDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func createNewBtnAction(_ sender: Any) {
        delegate?.createAccountInfoTap(.createNew)
    }
    
    @IBAction func unarchiveBtnAction(_ sender: Any) {
        delegate?.createAccountInfoTap(.unarchive)
    }

    @IBAction func notificationBtnAction(_ sender: Any) {
        delegate?.createAccountInfoTap(.notification)
    }
    
}
