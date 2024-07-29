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
        self.navigationController?.popViewController(animated: true)
        
        if isEmailVerification == true {
            
        }else {
            
        }
        if isPhoneVerification == true {
            
        }else {
            if let phoneVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "PhoneVerifyVC"){
                self.navigate(to: forgotVC)
            }
        }
        
    }
    
    @IBAction func resendCodeBtn(_ sender: Any) {
        
        if isEmailVerification == true {
            
        }else {
            
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
            print("Verification Code: \(verificationCode)")
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
    func getVerificationCode() -> String {
        let code1 = tf_firstNum.text ?? ""
        let code2 = tf_SecondNum.text ?? ""
        let code3 = tf_thirdNum.text ?? ""
        let code4 = tf_fourthNum.text ?? ""
        let code5 = tf_fivethNum.text ?? ""
        
        let code = code1 + code2 + code3 + code4 + code5
        return code
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
}
