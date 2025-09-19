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
    @IBOutlet weak var lbl_email: UILabel!
    @IBOutlet weak var progreeBar: UIProgressView!
    //    @IBOutlet weak var view_profileComplete: CardView!
    @IBOutlet weak var lbl_progressPercent: UILabel!
    
    @IBOutlet weak var imageIcon: UIImageView!
    
    @IBOutlet weak var btn_edit: UIButton!
    @IBOutlet weak var btn_editProfile: UIButton!
    @IBOutlet weak var lbl_profile: UILabel!
    
    @IBOutlet weak var btn_completeProfile: UIButton!
    @IBOutlet weak var lbl_completeProfile: UILabel!
    
    weak var delegate: CompleteProfileButtonDelegate?
    weak var editDelegate: ProfileEditButtonDelegate?
    
    var fireStoreInstance = FirestoreServices()
    var profileStep = Int()
    var status = String()
    var userId = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if GlobalVariable.instance.guestAccount {
            btn_editProfile.isUserInteractionEnabled = false
            btn_edit.isHidden = true
            lbl_email.isHidden = true
            lbl_title.text = "Guest User"
        }else{
            btn_editProfile.isEnabled = true
            btn_edit.isHidden = false
            lbl_email.isHidden = false
        }
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String{
                lbl_email.text = _email
            }
        }
        
        checkProfileStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileData(_:)), name: Notification.Name("UpdateProfileData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileDataStatus(_:)), name: Notification.Name("UpdateProfileDataStatus"), object: nil)
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
               
//               if let type = userInfo["type"] as? String {
//                   print("this is profile VC and notification type is : \(type)")
//               }
//               
//               if let _status = userInfo["status"] as? String {
//                   self.status = _status
//                   print("\n push notification _status is : \(_status)")
//                   UserDefaults.standard.set(_status, forKey: "statusKYC")
//               }
           }
       }
       
    @objc func updateProfileDataStatus(_ notification: Notification){
        checkProfileStatus()
        updateUser()
        //  public final static String Not_Started="Not Started";public final static String Wait ="in progress";public final static String Complete ="Complete";//allow to deposit and withdraw public final static String Refer ="Refer";//allow to deposit and not withdraw public final static String Rejected = "Rejected";//allow only open real account public final static String Approved ="Approved";//allow to deposit and not withdraw public final static String Incomplete ="Incomplete";//allow to deposit and not withdraw    KycStatus
        
    }
       deinit {
           // Remove observer when the view controller is deallocated
           NotificationCenter.default.removeObserver(self, name: Notification.Name("UpdateProfileData"), object: nil)
           NotificationCenter.default.removeObserver(self, name: Notification.Name("UpdateProfileDataStatus"), object: nil)
       }
    
    func updateUser(){
       
        var fieldsToUpdate: [String: Any] = [
            "KycStatus" : self.status
        ]
        
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("user fields KYC Status update successfuly")
            }
        }
    }
    
    func checkProfileStatus() {
        
        if let kycStatus = UserDefaults.standard.string(forKey: "statusKYC"){
            self.status = kycStatus
        }
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data Profile screen: \(savedUserData)")
            if let _profileStep = savedUserData["profileStep"] as? Int, let _name = savedUserData["fullName"] as? String, let _userId = savedUserData["uid"] as? String {
                userId = _userId
                profileStep = _profileStep
                if let imageData = UserDefaults.standard.data(forKey: "userProfileImage"),
                   let savedImage = UIImage(data: imageData) {
                    imageIcon.image = savedImage
                }else{
                    imageIcon.image = UIImage(systemName: "person.circle")
                }
                lbl_title.text = _name
            }
        }
     
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            print("\n Default Account user in profile screen: \(defaultAccount)")
           
           let realAccount = defaultAccount.isReal == true ? true : false
            if realAccount == true {
                        if profileStep == 2 {
                           
                            if status == "Approved" {
                                lbl_profile.text = "Thank you for providing your details."
//                                btn_completeProfile.isUserInteractionEnabled = true
                                btn_completeProfile.setTitle("Profile Completed and KYC is Done.", for: .normal)
                                progreeBar.progress = 1.0
//                                self.lbl_progressPercent.text = "100%"
                               } else if status == "Rejected" {
                                   // Handle the "reject" status
                                  
                                   lbl_profile.text = "Your profile has been rejected. Please contact customer support for further details."
//                                   btn_completeProfile.isUserInteractionEnabled = false
                                   btn_completeProfile.setTitle("Profile in Progress", for: .normal)
                                   progreeBar.progress = 0.8
//                                   self.lbl_progressPercent.text = "90%"
                               } else{
                                   // Handle the "refer" status
                                   lbl_profile.text = "Thank you for providing your details."/* Your profile has been submitted for review. Please await further updates."*/
//                                   btn_completeProfile.isUserInteractionEnabled = true
                                   btn_completeProfile.setTitle("Profile Completed and KYC is Done.", for: .normal)
                                   progreeBar.progress = 1.0
//                                   self.lbl_progressPercent.text = "90%"
                               }
                        }else if profileStep == 1 {
                            progreeBar.progress = 0.67
//                            self.lbl_progressPercent.text = "67%"
//                            btn_completeProfile.isUserInteractionEnabled = true
                            btn_completeProfile.setTitle("Click to complete KYC", for: .normal)
    //                        self.btn_completeProfile.isHidden = false
                            lbl_profile.text = "You're almost done with your profile! The final step—KYC verification—is still pending."
                        }else{
                            lbl_profile.text = "We require some details from you to enable deposit and withdrawal options for your account."
                            progreeBar.progress = 0.0
                            self.lbl_progressPercent.text = "0%"
//                            btn_completeProfile.isUserInteractionEnabled = true
                            btn_completeProfile.setTitle("Complete your Profile and KYC", for: .normal)
                        }
                    }else{
                        progreeBar.progress = 0.0
                        self.lbl_progressPercent.text = "0%"
//                        btn_completeProfile.isUserInteractionEnabled = true
                        btn_completeProfile.setTitle("Complete your Profile and KYC", for: .normal)
                      
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
