//
//  ResidencVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/12/2024.
//

import UIKit
import CountryPickerView
import GoogleSignIn

class ResidencVC: BaseViewController {
    @IBOutlet weak var view_residencyCountryPicker: CountryPickerView!

    @IBOutlet weak var btn_residenceCheck: UIButton!
    @IBOutlet weak var tf_residencyField: UITextField!
    @IBOutlet weak var btn_confirm: CardViewButton!
    @IBOutlet weak var lbl_checkResidence: UILabel!
    
    var googleUser = GIDGoogleUser()
    
    var fireStoreInstance = FirestoreServices()
    let userId =  UserDefaults.standard.string(forKey: "userID")
    var nationality = String()
    
    var isOpenAccount = Bool()
//    var isGoogleAccount = Bool()
//    var isAppleLogin = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isOpenAccount =  UserDefaults.standard.bool(forKey: "fromOpenAccount")
//        isGoogleAccount =  UserDefaults.standard.bool(forKey: "isGoogleLogin")
//        isAppleLogin =  UserDefaults.standard.bool(forKey: "isAppleLogin")
//       print("isOpenAccount: \(isOpenAccount) ,isGoogleAccount: \(isGoogleAccount) ,isAppleLogin: \(isAppleLogin)")
//
        view_residencyCountryPicker.delegate = self
        view_residencyCountryPicker.showPhoneCodeInView = false
        view_residencyCountryPicker.showCountryCodeInView = false
        view_residencyCountryPicker.showCountryNameInView = false
        view_residencyCountryPicker.flagImageView.isHidden = false
       
//        odoClientNew.createLeadDelegate = self
//        self.googleSignIn.odoClientNew.createLeadDelegate = self

        self.tf_residencyField.isUserInteractionEnabled = false
        self.btn_confirm.isUserInteractionEnabled = false
        self.btn_confirm.tintColor = .systemGray
        self.btn_confirm.layer.borderColor =   UIColor.systemGray.cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkResidence_action))
        lbl_checkResidence.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
       
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: NationalityVC(), navController: self.navigationController, title: "Residence", leftTitle: "", rightTitle: "", textColor: .white, barColor: .clear)
    }
    
  
    @IBAction func checkResidence_action(_ sender: Any) {
        self.btn_residenceCheck.isSelected = !self.btn_residenceCheck.isSelected
        self.btn_residenceCheck.setImage(!self.btn_residenceCheck.isSelected ? UIImage(systemName: "square")?.withTintColor(.white) : UIImage(systemName: "checkmark.square")?.withTintColor(.systemYellow), for: .normal)
       
        if self.btn_residenceCheck.isSelected {
            self.btn_confirm.isUserInteractionEnabled = true
            self.btn_confirm.tintColor = .systemYellow
            self.btn_confirm.layer.borderColor =   UIColor.systemYellow.cgColor
        }else{
            self.btn_confirm.isUserInteractionEnabled = false
            self.btn_confirm.tintColor = .systemGray
            self.btn_confirm.layer.borderColor =   UIColor.systemGray.cgColor
        }
        
    }
    
    func blinkLabelColor(label: UILabel, toColor: UIColor, originalColor: UIColor) {
        // Change to red color
        UIView.animate(withDuration: 0.5, animations: {
            label.textColor = toColor
        }) { _ in
            // Revert to the original color after 1 second
            UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                label.textColor = originalColor
            })
        }
    }
    
    @IBAction func confirm_btnAction(_ sender: Any) {
        if !self.btn_residenceCheck.isSelected {
            ToastMessage("enable declear check.")
            blinkLabelColor(label: lbl_checkResidence, toColor: .systemRed, originalColor: .white)

            return
        }
        
        guard let _residence = tf_residencyField.text, !_residence.isEmpty else {
        ToastMessage("Select residence country first")
            return
        }
                
        if isOpenAccount {
            navigateTologin()
        }else{
            navigateToPassword()
        }
    }
    
    func navigateTologin(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "EmailVC") as! EmailVC
        self.navigate(to: dashboardVC)
    }
    
    func navigateToPassword(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let passwordVC = storyboard.instantiateViewController(withIdentifier: "PasswordVC") as! PasswordVC
        
//        if isGoogleAccount{
//            passwordVC.googleUser = googleUser
//           
//        }
//        passwordVC.isOpenAccount = isOpenAccount
//        passwordVC.isAppleLogin = isAppleLogin
//        passwordVC.isGoogleAccount = isGoogleAccount
        
        self.navigate(to: passwordVC)
    }
    
    func navigateFaceID(){
        
        let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
        faceIdVC.afterLoginNavigation = false
        self.navigate(to: faceIdVC)
    }
    
    func navigateToVerifiyScreen() {
        
        let verifyOTP = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! VerifyCodeViewController
       
        self.navigate(to: verifyOTP)
    }
    
    
}

extension ResidencVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
      
            tf_residencyField.text = country.name
            self.view_residencyCountryPicker.flagImageView.image = country.flag
        GlobalVariable.instance.residence = tf_residencyField.text ?? ""
        
    }
}
