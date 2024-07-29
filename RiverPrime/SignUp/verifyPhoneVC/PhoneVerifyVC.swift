//
//  PhoneVerifyVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 25/07/2024.
//

import UIKit
import CountryPickerView
import PhoneNumberKit

class PhoneVerifyVC: UIViewController {
    
    @IBOutlet weak var view_countryCode: CountryPickerView!
    
    @IBOutlet weak var tf_numberField: UITextField!
    
    var number = ""
    var selectedCountry: Country?
    let phoneNumberKit = PhoneNumberKit()
    
    let userId =  UserDefaults.standard.string(forKey: "userID")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view_countryCode.delegate = self
        view_countryCode.showPhoneCodeInView = false
        view_countryCode.showCountryCodeInView = false
        view_countryCode.showCountryNameInView = false
        view_countryCode.flagImageView.isHidden = false
        
        tf_numberField.text = view_countryCode.selectedCountry.phoneCode
        tf_numberField.delegate = self
        
    }
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        
        print("\(userId ?? "")")
        print(self.tf_numberField.text ?? "0000")
        guard let userId = userId,
              let phoneNumber = tf_numberField.text, !phoneNumber.isEmpty else {
            print("Please enter your phone number")
            return
        }
        do {
            let phoneNumber1 = try phoneNumberKit.parse(phoneNumber, withRegion: selectedCountry!.code, ignoreType: true)
                  let formattedNumber = phoneNumberKit.format(phoneNumber1, toType: .international)
            tf_numberField.text = formattedNumber
            updateUser()
              } catch {
                  showAlert(message: "Invalid phone number for the given country code")
              }
       
        if let verifyVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "VerifyCodeViewController"){
//            verifyVC.isPhoneVerification
            self.navigate(to: verifyVC)
        }
    }
    
    func updateUser(){
        guard let userId = userId,
              let phoneNumber = tf_numberField.text, !phoneNumber.isEmpty else {
            print("Please enter your phone number")
            return
        }
        let firestoreService = FirestoreServices()
        let fieldsToUpdate: [String: Any] = [
            "phone": phoneNumber,
            "phoneVerified": true
        ]
        
        firestoreService.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                self.showAlert(message: "Failed to update phone number. Please try again.")
            } else {
                print("User fields updated successfully!")
                self.showAlert(message: "Phone number verified successfully!", completion: {
                    // Optionally, navigate to the next screen or dismiss this screen
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
//            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}
extension PhoneVerifyVC: CountryPickerViewDelegate, UITextFieldDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country){
        
        selectedCountry = country
        tf_numberField.text = country.phoneCode
        
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
