//
//  VerifyCodeViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit
import Firebase

protocol PhoneOTPDelegate: AnyObject {
    func didCompletePhoneOTPVerification()
}

class VerifyCodeViewController: BaseViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var tf_firstNum: UITextField!
    @IBOutlet weak var tf_SecondNum: UITextField!
    @IBOutlet weak var tf_thirdNum: UITextField!
    @IBOutlet weak var tf_fourthNum: UITextField!
    @IBOutlet weak var tf_fivethNum: UITextField!
    @IBOutlet weak var tf_sixthNum: UITextField!
    
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var label_errorCode: UILabel!
    @IBOutlet weak var lbl_remainingTime: UILabel!
    
    @IBOutlet weak var lbl_toComplete: UILabel!
    
    var countdownTimer: Timer?
    var remainingSeconds = 25
    
    var isEmailVerification: Bool?
    var isPhoneVerification: Bool?
    let userId =  UserDefaults.standard.string(forKey: "userID")
    
    var userPhone: String?
    
    let fireStoreInstance = FirestoreServices()
    //    let odooClientService = OdooClient()
    let odooClientService = OdooClientNew()
   
    weak var delegate: PhoneOTPDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
//        self.view.setGradientBackground()
        self.label_errorCode.isHidden = true
        
        odooClientService.otpDelegate = self
        odooClientService.verifyDelegate = self
        
        let textFields = [tf_firstNum, tf_SecondNum, tf_thirdNum, tf_fourthNum, tf_fivethNum, tf_sixthNum]
        
        for textField in textFields {
            textField?.delegate = self
            textField?.keyboardType = .numberPad
            textField?.textAlignment = .center
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
//        resendCodeButton.isEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.isEmailVerification == true {
                self.ToastMessage( "check email inbox/spam for OTP")
            }else{
                self.ToastMessage("check mobile message for OTP")
                
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if isPhoneVerification == false {
            lbl_toComplete.text = "We have sent you code to the provided Email.\n\nTo complete your Email verification, please enter the 6-digit activation code."
        }else{
            lbl_toComplete.text = "We have sent you code to the provided Number.\n\nTo complete your phone number verification, please enter the 6-digit activation code."
        }
        //MARK: - Show Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .white, barColor: .clear)
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        
        
    }
    
    func callApi(){
        if ((getVerificationCode()?.isEmpty) == nil) {
            print("please enter code")
            return
        }else{
            if isEmailVerification == true {
                //"verify the otp code func sent through email and set that function"
                //                odooClientService.verifyOTP(type: "email", email: userEmail, phone: "", otp: getVerificationCode() ?? "" )
                odooClientService.verifyOTP(type: "email", email: GlobalVariable.instance.userEmail, phone: "", otp: getVerificationCode() ?? "" )
                
                
            }else if isPhoneVerification == true {
                //                if let faceIDVC = self.instantiateViewController(fromStoryboard: "Main", withIdentifier: "PasscodeFaceIDVC"){
                //                    self.navigate(to: faceIDVC)
                //                } // for testing only
                
//                odooClientService.verifyOTP(type: "phone", email: GlobalVariable.instance.userEmail , phone: userPhone ?? "", otp: getVerificationCode() ?? "" )   // when live
                
//                self.delegate?.didCompletePhoneOTPVerification()
//                
//                self.dismiss(animated: true, completion: nil)
                updateUser()
            }
        }
    }
    
    func updateUser(){
        guard let userId = userId else{
            return
        }
        var fieldsToUpdate: [String: Any] = [:]
        
        if isEmailVerification == true {
            fieldsToUpdate = [
                "emailVerified" : true
            ]
            
        }else if isPhoneVerification == true {
            fieldsToUpdate = [
                "phone": self.userPhone,
                "phoneVerified" : true,
                "isLogin" : true,
                "pushedToCRM": true
            ]
        }
        
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                
                if self.isEmailVerification == true {
                    self.isEmailVerification = false
//                    self.navigateToPhoneVerifiyScreen()
                    print("User emailVerify fields updated successfully!")
                    self.fireStoreInstance.fetchUserData(userId: userId)
                    
                } else if self.isPhoneVerification == true {
                    self.isPhoneVerification = false
                    print("User isPhone fields updated successfully!")
                    self.fireStoreInstance.fetchUserData(userId: userId)
//                    self.navigateToFaceID()
                    self.delegate?.didCompletePhoneOTPVerification()
                    
                    self.dismiss(animated: true)
                    
                }
                
            }
        }
    }
    
//    func navigateToFaceID(){
//        if let residencVC = self.instantiateViewController(fromStoryboard: "Main", withIdentifier: "PasscodeFaceIDVC"){
//            self.navigate(to: residencVC)
//        }
//    }
    
    @IBAction func resendCodeBtn(_ sender: Any) {
        callMethodAfterDelay()
//        resendCodeButton.isEnabled = false
        
        
        //        resendCodeButton.setTitle("Resend in \(remainingSeconds) seconds", for: .disabled)
        
        // Start the countdown timer
        startCountdown()
        
        // Call your method after 60 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            self.callMethodAfterDelay()
        }
    }
    
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
    }
    
    // Method to update the button title each second
    @objc func updateButtonTitle() {
        remainingSeconds -= 1
        if remainingSeconds >= 0 {
            //            resendCodeButton.setTitle("Resend code in \(remainingSeconds) seconds", for: .disabled)
            self.lbl_remainingTime.text = "00:\(remainingSeconds)"
        } else {
            // Invalidate the timer and re-enable the button when the countdown finishes
            countdownTimer?.invalidate()
            countdownTimer = nil
            resendCodeButton.isEnabled = true
            //            resendCodeButton.setTitle("Resend Code", for: .normal)
            remainingSeconds = 25 // Reset the countdown time
        }
    }
    
    // Method to be called after the delay
    func callMethodAfterDelay() {
        // Add your method logic here
        print("Method called after 25 Second")
        
        if isEmailVerification == true {
            odooClientService.sendOTP(type: "email", email: GlobalVariable.instance.userEmail, phone: "")
        }else if isPhoneVerification == true {
            if let number = self.userPhone  {
                odooClientService.sendOTP(type: "phone", email: GlobalVariable.instance.userEmail, phone: number)
            }
            
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text.count == 1 else { return }
        
        switch textField {
        case tf_firstNum:
            tf_SecondNum.becomeFirstResponder()
        case tf_SecondNum:
            tf_thirdNum.becomeFirstResponder()
        case tf_thirdNum:
            tf_fourthNum.becomeFirstResponder()
        case tf_fourthNum:
            tf_fivethNum.becomeFirstResponder()
        case tf_fivethNum:
            tf_sixthNum.becomeFirstResponder()
        case tf_sixthNum:
            tf_sixthNum.resignFirstResponder()
            dismissKeyboard()
            // Optionally, get the combined string when the user finishes input
            
            let verificationCode = getVerificationCode()
            print("Verification Code: \(verificationCode ?? "")")
            callApi()
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        self.tf_firstNum.backgroundColor = .white
        self.tf_SecondNum.backgroundColor = .white
        self.tf_thirdNum.backgroundColor = .white
        self.tf_fourthNum.backgroundColor = .white
        self.tf_fivethNum.backgroundColor = .white
        self.tf_sixthNum.backgroundColor = .white
        
        if string.isEmpty { // Check for backspace
            if text.isEmpty {
                switch textField {
                case tf_firstNum:
                    tf_firstNum.becomeFirstResponder()
                case tf_SecondNum:
                    tf_firstNum.becomeFirstResponder()
                case tf_thirdNum:
                    tf_SecondNum.becomeFirstResponder()
                case tf_fourthNum:
                    tf_thirdNum.becomeFirstResponder()
                case tf_fivethNum:
                    tf_fourthNum.becomeFirstResponder()
                case tf_sixthNum:
                    tf_fivethNum.becomeFirstResponder()
                    
                default:
                    break
                }
            }
            return true
        }
        
        let newLength = text.count + string.count - range.length
        return newLength <= 1
    }
    
    // Method to get the combined string from all text fields
    func getVerificationCode() -> String? {
        
        guard
            let code1 = tf_firstNum.text, !code1.isEmpty,
            let code2 = tf_SecondNum.text, !code2.isEmpty,
            let code3 = tf_thirdNum.text, !code3.isEmpty,
            let code4 = tf_fourthNum.text, !code4.isEmpty,
            let code5 = tf_fivethNum.text, !code5.isEmpty,
            let code6 = tf_sixthNum.text, !code6.isEmpty
        else {
            print("Please fill in all fields.")
            self.ToastMessage("Please fill in all fields.")
            return nil
        }
        
        let code = code1 + code2 + code3 + code4 + code5 + code6
        return code
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    private func navigateToPhoneVerifiyScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "PhoneVerifyVC") as! PhoneVerifyVC
        
        self.navigate(to: verifyVC)
    }
    
}

extension VerifyCodeViewController: SendOTPDelegate {
    func otpSuccess(response: Any) {
        print("this is the email send otp response: \(response)")
        if isEmailVerification == true {
            self.ToastMessage("Check your email inbox or spam for OTP")
        }else{
            self.ToastMessage("Check your message for OTP")
            
        }
    }
    
    func otpFailure(error: Error) {
        print("this is the error  otp response: \(error)")
//        self.label_errorCode.isHidden = false
       
    }
}

extension VerifyCodeViewController:  VerifyOTPDelegate {
    func otpVerifySuccess(response: Any) {
        print("\nthis is the verify otp response: \(response)")
        
        if isEmailVerification == true {
            updateUser()
            self.ToastMessage("Email OTP Correct. Verify Phone Number")
            ActivityIndicator.shared.hide(from: self.view)
            
            self.tf_firstNum.backgroundColor = .systemGreen
            self.tf_SecondNum.backgroundColor = .systemGreen
            self.tf_thirdNum.backgroundColor = .systemGreen
            self.tf_fourthNum.backgroundColor = .systemGreen
            self.tf_fivethNum.backgroundColor = .systemGreen
            self.tf_sixthNum.backgroundColor = .systemGreen
            
            navigateToPhoneVerifiyScreen()
        }else{
            self.tf_firstNum.backgroundColor = .systemGreen
            self.tf_SecondNum.backgroundColor = .systemGreen
            self.tf_thirdNum.backgroundColor = .systemGreen
            self.tf_fourthNum.backgroundColor = .systemGreen
            self.tf_fivethNum.backgroundColor = .systemGreen
            self.tf_sixthNum.backgroundColor = .systemGreen
            
            self.ToastMessage("Phone Number OTP Correct.")
            updateUser()
        }
    }
    
    func otpVerifyFailure(error: Error) {
        
        print("this is the error from verify otp response: \(error)")
        self.label_errorCode.isHidden = false
        
        self.tf_firstNum.backgroundColor = .systemRed
        self.tf_SecondNum.backgroundColor = .systemRed
        self.tf_thirdNum.backgroundColor = .systemRed
        self.tf_fourthNum.backgroundColor = .systemRed
        self.tf_fivethNum.backgroundColor = .systemRed
        self.tf_sixthNum.backgroundColor = .systemRed
    }
}
