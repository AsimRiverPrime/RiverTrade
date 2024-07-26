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
      
        guard let numberText = tf_numberField.text else { return }
        guard let country = selectedCountry else { return }

        print(self.tf_numberField.text ?? "0000")

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
               textField.text = formattedNumber
               return false
           } catch {
               print("Error formatting phone number: \(error)")
               return true
           }
       }
    
}
