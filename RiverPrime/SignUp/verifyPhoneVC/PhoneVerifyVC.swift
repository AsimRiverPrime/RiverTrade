//
//  PhoneVerifyVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 25/07/2024.
//

import UIKit
import CountryPickerView
import PhoneNumberKit
import Firebase

class PhoneVerifyVC: BaseViewController{
    
    @IBOutlet weak var view_countryCode: CountryPickerView!
    
    @IBOutlet weak var tf_numberField: UITextField!
    
  
    var number = ""
    var selectedCountry: Country?
    let phoneNumberKit = PhoneNumberKit()
    
    let userId =  UserDefaults.standard.string(forKey: "userID")
    var userEmail: String = ""
    var firestoreService = FirestoreServices()
//    let oodoService = OdooClient()
    let oodoServiceNew = OdooClientNew()
    
    weak var delegate: PhoneVerifyDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setGradientBackground()
        
//        oodoService.delegate = self
//        oodoService.updateNumberDelegate = self
        oodoServiceNew.updateNumberDelegate = self
//        oodoServiceNew.otpDelegate = self
//        oodoServiceNew.updateNumberDelegate = self
        
        view_countryCode.delegate = self
        view_countryCode.showPhoneCodeInView = false
        view_countryCode.showCountryCodeInView = false
        view_countryCode.showCountryNameInView = false
        view_countryCode.flagImageView.isHidden = false
        
        tf_numberField.delegate = self
      
        let currentCountry = CountryManager.shared.selectedCountry
        view_countryCode.flagImageView.image = currentCountry?.flag
        tf_numberField.text = currentCountry?.phoneCode
        selectedCountry = currentCountry
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Show Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        
        print("userID: \(userId ?? "")")
        print(self.tf_numberField.text ?? "")
        print(self.selectedCountry ?? "")
        
        guard let userId = userId, let selectedCountry = selectedCountry,
              let phoneNumber = tf_numberField.text, !phoneNumber.isEmpty else {
            
            print("Please enter your phone number")
            self.ToastMessage("Please enter your phone number")
            return
        }
        do {
            let phoneNumber1 = try phoneNumberKit.parse(phoneNumber, withRegion: selectedCountry.code, ignoreType: true)
                let formattedNumber = phoneNumberKit.format(phoneNumber1, toType: .international)
            tf_numberField.text = formattedNumber
            UserDefaults.standard.set(tf_numberField.text, forKey: "phoneNumber")
            self.oodoServiceNew.writeRecords(number: self.tf_numberField.text ?? "") // update the CRM with user phoneNumber
            
              } catch {
                  showAlert(message: "Invalid phone number for the given country code")
            }
    }
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func navigateToVerifiyScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
       
        verifyVC.isEmailVerification = false
        verifyVC.isPhoneVerification = true
        verifyVC.userPhone = self.tf_numberField.text ?? "0000"
        verifyVC.delegate = self
        self.navigate(to: verifyVC)
    }
    
//    private func navigateTofaceIDScreen() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let faceID = storyboard.instantiateViewController(withIdentifier: "PasscodeFaceIDVC")
//        self.navigate(to: faceID)
//
//    }
    func updateUser(){
        guard let userId = userId else{
            return
        }
        
        let fieldsToUpdate: [String: Any] = [
            "phone": self.tf_numberField.text ?? "",
            "phoneVerified" : true,
            "isLogin" : true,
            "pushedToCRM": true
        ]
        
        
        firestoreService.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                
                print("User isPhone fields updated successfully!")
                self.firestoreService.fetchUserData(userId: userId)
                //                    self.navigateToFaceID()
                self.delegate?.didCompletePhoneVerification()
//                self.delegate?.didCompletePhoneOTPVerification()
                if GlobalVariable.instance.realAccount {
                    Session.instance.isRealAccountInitFlowComplete = true
                    self.initKYC_CheckData()
                } else {
                    self.dismiss(animated: true)
                }
//                self.dismiss(animated: true)
                
            }
        }
    }
}

extension PhoneVerifyVC {
    
    func initKYC_CheckData(){
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let profileStep1 = savedUserData["profileStep"] as? Int, let _email = savedUserData["email"] as? String, let _userId = savedUserData["id"] as? String, let _registrationType = savedUserData["registrationType"] as? Int, let _isPhoneVerified = savedUserData["phoneVerified"] as? Bool, let _isEmailVerified = savedUserData["emailVerified"] as? Bool  {
//                profileStep = profileStep1
//                userEmail = _email
//                registrationType = _registrationType
//                isPhoneVerified = _isPhoneVerified
//                isEmailVerified = _isEmailVerified
//                UserDefaults.standard.set(_userId, forKey: "userID")
                didCompleteKYCVerification(profileStep1: profileStep1)
            }
        }
        
    }
    
    func didCompleteKYCVerification(profileStep1: Int) {
        // After phone verification is complete, check profileStep
        switch profileStep1 {
        case 0:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        case 1:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            //               case 2:
            //                   let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            //                   vc.delegateKYC = self
            //                   PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        default:
            self.ToastMessage("Already Done KYC")
        }
    }
    
}

extension PhoneVerifyVC: PhoneOTPDelegate {
    func didCompletePhoneOTPVerification() {
        self.delegate?.didCompletePhoneVerification()
        self.dismiss(animated: true)
       
    }

}
// MARK: - delegate from phone number OTP
//extension PhoneVerifyVC:  SendOTPDelegate {
    
//    func otpSuccess(response: Any) {
//        print("this is the phone send otp response: \(response)")
//        navigateToVerifiyScreen()
//
//    }
//
//    func otpFailure(error: any Error) {
//        print("this is the phone send otp error response: \(error)")
//    }
//}
// MARK: - delegate from update number Method on CRM
extension PhoneVerifyVC: UpdatePhoneNumebrDelegate {
    func updateNumberSuccess(response: Any) {
        print("the phone number update successfuly response is: \(response)")
        
        var number = self.tf_numberField.text ?? ""
 
        number = number.replacingOccurrences(of: " ", with: "")
        print("number is: \(number)")
//        oodoServiceNew.sendOTP(type: "phone", email: GlobalVariable.instance.userEmail, phone: number)
//        navigateTofaceIDScreen()
//        navigateToVerifiyScreen()
        updateUser()
    }
    
    func updateNumberFailure(error: any Error) {
        print("this is the update phone number error response: \(error)")
    }
    
    
}
extension PhoneVerifyVC: CountryPickerViewDelegate, UITextFieldDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country){
        
        selectedCountry = country
        tf_numberField.text = country.phoneCode
        view_countryCode.flagImageView.image = country.flag
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let country = selectedCountry else { return true }
        
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        do {
            let phoneNumber = try phoneNumberKit.parse(currentText, withRegion: country.code, ignoreType: true)
            let formattedNumber = phoneNumberKit.format(phoneNumber, toType: .international)
            tf_numberField.text = formattedNumber
            return false
        } catch {
            print("Error formatting phone number: \(error)")
            return true
        }
    }
    
}

extension PhoneVerifyVC: KYCVCDelegate {
    
    func navigateToCompeletProfile(kyc: KYCType) {
        switch kyc {
        case .ProfileScreen:
            
//            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "ProfileViewController") {
//                //                GlobalVariable.instance.isReturnToProfile = true
//                self.navigate(to: profileVC)
//            }
            
            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "HomeTabbarViewController"){
                //                profileVC.delegateKYC = self
                //                GlobalVariable.instance.isReturnToProfile = true
                self.navigate(to: profileVC)
            }
            break
        case .FirstScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .SecondScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen2, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen2
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .ThirdScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen3, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen3
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .FourthScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen4, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen4
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .FifthScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen5, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen5
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .SixthScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen6, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen6
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .SeventhScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen7, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen7
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .ReturnDashboard:
//            initTableView_CheckData()
          
                let profilevc = Utilities.shared.getViewController(identifier: .profileViewController, storyboardType: .dashboard) as! ProfileViewController
                profilevc.delegateKYC = self
                self.navigate(to: profilevc)
            
            break
        case .KycScreen:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        }
    }
    
}
