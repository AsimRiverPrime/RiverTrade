//
//  VerifyCodeViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit
import Firebase

class VerifyCodeViewController: BaseViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var tf_firstNum: UITextField!
    @IBOutlet weak var tf_SecondNum: UITextField!
    @IBOutlet weak var tf_thirdNum: UITextField!
    @IBOutlet weak var tf_fourthNum: UITextField!
    @IBOutlet weak var tf_fivethNum: UITextField!
    @IBOutlet weak var tf_sixthNum: UITextField!
    
    @IBOutlet weak var resendCodeButton: UIButton!
    
    var countdownTimer: Timer?
    var remainingSeconds = 60
    
    var isEmailVerification: Bool?
    var isPhoneVerification: Bool?
    let userId =  UserDefaults.standard.string(forKey: "userID")
    
    var userPhone: String?
    
    
    let fireStoreInstance = FirestoreServices()
    //    let odooClientService = OdooClient()
    let odooClientService = OdooClientNew()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        odooClientService.otpDelegate = self
        odooClientService.verifyDelegate = self
        
        let textFields = [tf_firstNum, tf_SecondNum, tf_thirdNum, tf_fourthNum, tf_fivethNum, tf_sixthNum]
        
        for textField in textFields {
            textField?.delegate = self
            textField?.keyboardType = .numberPad
            textField?.textAlignment = .center
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
        resendCodeButton.isEnabled = true
        
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        if ((getVerificationCode()?.isEmpty) == nil) {
            print("please enter code")
            return
        }else{
            if isEmailVerification == true {
                //"verify the otp code func sent through email and set that function"
                //                odooClientService.verifyOTP(type: "email", email: userEmail, phone: "", otp: getVerificationCode() ?? "" )
                odooClientService.verifyOTP(type: "email", email: GlobalVariable.instance.userEmail, phone: "", otp: getVerificationCode() ?? "" )
                
                
            }else if isPhoneVerification == true {
                if let faceIDVC = self.instantiateViewController(fromStoryboard: "Main", withIdentifier: "PasscodeFaceIDVC"){
                    self.navigate(to: faceIDVC)
                } // for testing only
                
                //                odooClientService1.verifyOTP(type: "phone", email: GlobalVariable.instance.userEmail , phone: userPhone, otp: getVerificationCode() ?? "" )    when live
                
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
                "login" : true,
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
                    
                    if let faceIDVC = self.instantiateViewController(fromStoryboard: "Main", withIdentifier: "PasscodeFaceIDVC"){
                        self.navigate(to: faceIDVC)
                    }
                }
                
            }
        }
    }
    
    @IBAction func resendCodeBtn(_ sender: Any) {
        
        resendCodeButton.isEnabled = false
        resendCodeButton.setTitle("Resend in \(remainingSeconds) seconds", for: .disabled)
        
        // Start the countdown timer
        startCountdown()
        
        // Call your method after 60 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
            self.callMethodAfterDelay()
        }
    }
    
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
    }
    
    // Method to update the button title each second
    @objc func updateButtonTitle() {
        remainingSeconds -= 1
        if remainingSeconds > 0 {
            resendCodeButton.setTitle("Resend code in \(remainingSeconds) seconds", for: .disabled)
        } else {
            // Invalidate the timer and re-enable the button when the countdown finishes
            countdownTimer?.invalidate()
            countdownTimer = nil
            resendCodeButton.isEnabled = true
            resendCodeButton.setTitle("Resend Code", for: .normal)
            remainingSeconds = 60 // Reset the countdown time
        }
    }
    
    // Method to be called after the delay
    func callMethodAfterDelay() {
        // Add your method logic here
        print("Method called after 1 minute")
        
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
            
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
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
        //        if let verifyVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "PhoneVerifyVC"){
        //            verifyVC.userEmail = userEmail
        //            self.navigate(to: verifyVC)
        //        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "PhoneVerifyVC") as! PhoneVerifyVC
        //        verifyVC.userEmail = userEmail
        self.navigate(to: verifyVC)
    }
    
}

extension VerifyCodeViewController: SendOTPDelegate {
    func otpSuccess(response: Any) {
        print("this is the send otp response: \(response)")
        self.ToastMessage("Please check Your email for OTP")
    }
    
    func otpFailure(error: Error) {
        print("this is the error  otp response: \(error)")
        
    }
}

extension VerifyCodeViewController:  VerifyOTPDelegate {
    func otpVerifySuccess(response: Any) {
        print("\nthis is the verify otp response: \(response)")
        
        if isEmailVerification == true {
            updateUser()
            self.ToastMessage("OTP Correct. Verify Phone#")
            
            ActivityIndicator.shared.hide(from: self.view)
            navigateToPhoneVerifiyScreen()
        }else{
            updateUser()
        }
    }
    
    func otpVerifyFailure(error: Error) {
        
        print("this is the error from verify otp response: \(error)")
    }
}
