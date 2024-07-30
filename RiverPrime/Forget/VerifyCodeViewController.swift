//
//  VerifyCodeViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit

class VerifyCodeViewController: BaseViewController, UITextFieldDelegate{
    
    @IBOutlet weak var tf_firstNum: UITextField!
    @IBOutlet weak var tf_SecondNum: UITextField!
    @IBOutlet weak var tf_thirdNum: UITextField!
    @IBOutlet weak var tf_fourthNum: UITextField!
    @IBOutlet weak var tf_fivethNum: UITextField!
    
    var isEmailVerification: Bool?
    var isPhoneVerification: Bool?
    let userId =  UserDefaults.standard.string(forKey: "userID")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textFields = [tf_firstNum, tf_SecondNum, tf_thirdNum, tf_fourthNum, tf_fivethNum]
        
        for textField in textFields {
            textField?.delegate = self
            textField?.keyboardType = .numberPad
            textField?.textAlignment = .center
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        if ((getVerificationCode()?.isEmpty) == nil) {
            print("please enter code")
            return
        }else{
            if isEmailVerification == true {
                 print("verify the code func sent through email and set that function")
                updateUser()
                navigateToVerifiyScreen()
            }else if isPhoneVerification == true {
                print("verify the code func sent through phone number and set that function")
                updateUser()
                if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
                    self.navigate(to: dashboardVC)
                }
            }
        }
        
      
        
        
    }
    
    
    func updateUser(){
        guard let userId = userId else{
            return
        }
        var fieldsToUpdate: [String: Any] = [:]
        
        let firestoreService = FirestoreServices()
        
        if isEmailVerification == true {
            fieldsToUpdate = [
                "emailVerified" : true
            ]
        }else if isPhoneVerification == true {
            fieldsToUpdate = [
                "phoneVerified" : true
            ]
        }
        
        firestoreService.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
//                self.showAlert(message: "Failed to update phone number. Please try again.")
                return
            } else {
                print("User fields updated successfully!")
//                self.showAlert(message: "Phone number verified successfully!", completion: {
//                    // Optionally, navigate to the next screen or dismiss this screen
//                    self.dismiss(animated: true, completion: nil)
//                })
                
                
            }
        }
    }
    
    @IBAction func resendCodeBtn(_ sender: Any) {
        
        if isEmailVerification == true {
            
        }else if isPhoneVerification == true {
            
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
            tf_fivethNum.resignFirstResponder()
            dismissKeyboard()
            // Optionally, get the combined string when the user finishes input
            
            let verificationCode = getVerificationCode()
            print("Verification Code: \(verificationCode ?? "")")
            
            if isEmailVerification == true {
                print("Call the email code verification method")
            }else if isPhoneVerification == true {
                print("Call the phone code verification method")
            }
            
        default:
            break
        }
        
        if text.count == 0 {
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
                
            default:
                break
            }
        }else{
            
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
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
            let code5 = tf_fivethNum.text, !code5.isEmpty
        else {
            print("Please fill in all fields.")
            return nil
        }
        
        let code = code1 + code2 + code3 + code4 + code5
        return code
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    private func navigateToVerifiyScreen() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let verifyVC = storyboard.instantiateViewController(withIdentifier: "PhoneVerifyVC") as! PhoneVerifyVC
//        self.navigationController?.pushViewController(verifyVC, animated: true)
//        self.navigate(to: verifyVC)
        if let verifyVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "PhoneVerifyVC"){
            self.navigate(to: verifyVC)
        }
    }
    
}
