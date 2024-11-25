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
    func createAccountInfoTap1(_ createAccountInfo: CreateAccountInfo)
}

class CreateAccountTVCell: UITableViewCell {

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var secondTitle: UILabel!
    @IBOutlet weak var lbl_greeting: UILabel!
    
//    @IBOutlet weak var viewOfAccount: UIStackView!
//    @IBOutlet weak var viewOfBtnStack: UIView!
        
    @IBOutlet weak var heightOfAccountHeaderView: NSLayoutConstraint!
//    @IBOutlet weak var widthOfMainStackView: NSLayoutConstraint!
    
    weak var delegate: CreateAccountInfoDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
        if let loginID = savedUserData["loginId"] as? Int,
           let _name = savedUserData["name"] as? String {
           
//            self.login_Id = loginID
            self.headerTitle.text = _name
//            
//            if isCreateDemoAccount == true {
//                self.account_type = " Demo "
//                mt5 = " MT5 "
//                self.account_group = " \(accountType) "
//            }
//            if isRealAccount == true {
//                self.account_type = " Real "
//                mt5 = " MT5 "
//                self.account_group = " \(accountType) "
//            }
//            
//            
//            if accountType == "Pro Account" {
//                self.account_group = " PRO "
//                mt5 = " MT5 "
//            }else if accountType == "Prime Account" {
//                self.account_group = " PRIME "
//                mt5 = " MT5 "
//            }else if accountType == "Premium Account" {
//                self.account_group = " PREMIUM "
//                mt5 = " MT5 "
//            }else{
////                    self.account_group = ""
////                    mt5 = ""
//                
//            }
        }
    }
    
    let currentHour = Calendar.current.component(.hour, from: Date())
    var greeting = ""

    switch currentHour {
    case 5..<12:
        greeting = "Good Morning,"
    case 12..<17:
        greeting = "Good Afternoon,"
    case 17..<22:
        greeting = "Good Evening,"
    default:
        break
    }

    lbl_greeting.text = greeting
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func createNewBtnAction(_ sender: Any) {
        delegate?.createAccountInfoTap1(.createNew)
    }
    
//    @IBAction func unarchiveBtnAction(_ sender: Any) {
//        delegate?.createAccountInfoTap1(.unarchive)
//    }

    @IBAction func notificationBtnAction(_ sender: Any) {
        delegate?.createAccountInfoTap1(.notification)
    }
    
}
