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
    
    @IBOutlet weak var view_profileComplete: CardView!
    
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
            if let profileStep = savedUserData["profileStep"] as? Int {
                
                if profileStep == 3 {
                    self.btn_completeProfile.isHidden = true // or show popup "Thank you for providing your details. A Customer Support representative will reach out to you shortly with further instructions and to complete your account activation."
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func completeBtnAction(_ sender: UIButton) {
        delegate?.didTapCompleteProfileButtonInCell()
    }
    
}
