//
//  ProfileTopTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/07/2024.
//


import UIKit
import SDWebImage

protocol CompleteProfileButtonDelegate: AnyObject {
    func didTapCompleteProfileButtonInCell()
}
protocol ProfileEditButtonDelegate: AnyObject {
    func didTapEditButtonInCell()
}

class ProfileTopTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var progreeBar: UIProgressView!
    //    @IBOutlet weak var view_profileComplete: CardView!
    @IBOutlet weak var lbl_progressPercent: UILabel!
    
    @IBOutlet weak var imageIcon: UIImageView!
    
    @IBOutlet weak var btn_edit: UIButton!
    @IBOutlet weak var lbl_profile: UILabel!
    
    @IBOutlet weak var btn_completeProfile: UIButton!
    
    weak var delegate: CompleteProfileButtonDelegate?
    weak var editDelegate: ProfileEditButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkProfileStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileData(_:)), name: Notification.Name("UpdateProfileData"), object: nil)

    }
    @objc func updateProfileData(_ notification: Notification) {
           // Retrieve the user info dictionary from the notification
           if let userInfo = notification.userInfo {
               if let updatedImage = userInfo["profileImage"] as? UIImage {
                   imageIcon.image = updatedImage
               }
               if let updatedName = userInfo["userName"] as? String {
                   lbl_title.text = updatedName
               }
           }
       }
       
       deinit {
           // Remove observer when the view controller is deallocated
           NotificationCenter.default.removeObserver(self, name: Notification.Name("UpdateProfileData"), object: nil)
       }
    
    func checkProfileStatus() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            if let profileStep = savedUserData["profileStep"] as? Int, let realAccount = savedUserData["realAccountCreated"] as? Bool,let _name = savedUserData["name"] as? String {
                
                if let imageData = UserDefaults.standard.data(forKey: "userProfileImage"),
                   let savedImage = UIImage(data: imageData) {
                    imageIcon.image = savedImage
                }else{
                    imageIcon.image = UIImage(named: "avatarIcon")
                }
                
                
                lbl_title.text = _name
                
                if realAccount == true {
                    
                }else{
//                    Alert.showAlert(withMessage: "First create Real Account" , andTitle: "Alert!", on: self)
                }
                if profileStep == 3 {
//                    self.view_profileComplete.isHidden = true // or show popup "Thank you for providing your details. A Customer Support representative will reach out to you shortly with further instructions and to complete your account activation."
                    progreeBar.progress = 100.0
                    self.lbl_progressPercent.text = "100%"
                    btn_completeProfile.isUserInteractionEnabled = false
                    btn_completeProfile.setTitle("Profile Completed", for: .normal)
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func editBtnAction(_ sender: Any) {
        editDelegate?.didTapEditButtonInCell()
    }
    
    @IBAction func completeBtnAction(_ sender: UIButton) {
        delegate?.didTapCompleteProfileButtonInCell()
        
    }
    
}
