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
    @IBOutlet weak var lbl_completeProfile: UILabel!
    
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
                    if profileStep == 3 {
                        //self.view_profileComplete.isHidden = true // or show popup "Thank you for providing your details. A Customer Support representative will reach out to you shortly with further instructions and to complete your account activation."
                        progreeBar.progress = 1.0
                        self.lbl_progressPercent.text = "100%"
                        btn_completeProfile.isUserInteractionEnabled = false
                        btn_completeProfile.setTitle("Profile Completed", for: .normal)
                        self.btn_completeProfile.isHidden = true
                        lbl_completeProfile.text = "Profile Completed"
                    }else if profileStep == 2 {
                        progreeBar.progress = 0.67
                        self.lbl_progressPercent.text = "67%"
                        btn_completeProfile.isUserInteractionEnabled = true
                        btn_completeProfile.setTitle("", for: .normal)
                        self.btn_completeProfile.isHidden = false
                        lbl_completeProfile.text = "Welldone you complete your Profile almost.The last step KYC remaining."
                    }else if profileStep == 1 {
                        progreeBar.progress = 0.33
                        self.lbl_progressPercent.text = "33%"
                        btn_completeProfile.isUserInteractionEnabled = true
                        btn_completeProfile.setTitle("", for: .normal)
                        self.btn_completeProfile.isHidden = false
                        lbl_completeProfile.text = "Complete your Profile"
                    }else{
                        progreeBar.progress = 0.0
                        self.lbl_progressPercent.text = "0%"
                        btn_completeProfile.isUserInteractionEnabled = true
                        btn_completeProfile.setTitle("Complete your Profile", for: .normal)
                        self.btn_completeProfile.isHidden = false
                    }
                }else{
                    progreeBar.progress = 0.0
                    self.lbl_progressPercent.text = "0%"
                    btn_completeProfile.isUserInteractionEnabled = true
                    btn_completeProfile.setTitle("Complete your Profile", for: .normal)
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
