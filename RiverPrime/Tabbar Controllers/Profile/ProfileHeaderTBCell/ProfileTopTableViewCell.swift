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
//    override func layoutSubviews() {
//            super.layoutSubviews()
//
//            // Apply UIBezierPath for rounding bottom-left and bottom-right corners
//            let path = UIBezierPath(roundedRect: btn_completeProfile.bounds,
//                                    byRoundingCorners: [.bottomLeft, .bottomRight],
//                                    cornerRadii: CGSize(width: 20, height: 20)) // Adjust the radius as needed
//
//            let mask = CAShapeLayer()
//            mask.path = path.cgPath
//            btn_completeProfile.layer.mask = mask
//        }

    
    func checkProfileStatus() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            if let profileStep = savedUserData["profileStep"] as? Int, let realAccount = savedUserData["realAccountCreated"] as? Bool {
                if realAccount == true {
                    
                }else{
//                    Alert.showAlert(withMessage: "First create Real Account" , andTitle: "Alert!", on: self)
                }
                if profileStep == 3 {
                    self.view_profileComplete.isHidden = true // or show popup "Thank you for providing your details. A Customer Support representative will reach out to you shortly with further instructions and to complete your account activation."
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
