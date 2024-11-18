//
//  ProfileTopTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/07/2024.
//


import UIKit

protocol CompleteProfileButtonDelegate: AnyObject {
    func didTapCompleteProfileButtonInCell()
}

class ProfileTopTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var progreeBar: UIProgressView!
    //    @IBOutlet weak var view_profileComplete: CardView!
    @IBOutlet weak var lbl_progressPercent: UILabel!
    
    @IBOutlet weak var imageIcon: UIImageView!
    
    @IBOutlet weak var lbl_profile: UILabel!
    
    @IBOutlet weak var btn_completeProfile: UIButton!
    
    weak var delegate: CompleteProfileButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkProfileStatus()
    }
 
    
    func checkProfileStatus() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            if let profileStep = savedUserData["profileStep"] as? Int, let realAccount = savedUserData["realAccountCreated"] as? Bool,let _name = savedUserData["name"] as? String, let _uid = savedUserData["uid"] as? String {
                UserDefaults.standard.set(_uid, forKey: "userID")
                lbl_title.text = _name
                
                if realAccount == true {
                    
                }else{
//                    Alert.showAlert(withMessage: "First create Real Account" , andTitle: "Alert!", on: self)
                }
                if profileStep == 3 {
//                    self.view_profileComplete.isHidden = true // or show popup "Thank you for providing your details. A Customer Support representative will reach out to you shortly with further instructions and to complete your account activation."
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func editBtnAction(_ sender: Any) {
        
    }
    
    @IBAction func completeBtnAction(_ sender: UIButton) {
//        delegate?.didTapCompleteProfileButtonInCell()
    }
    
}
