//
//  PhoneVerifyVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 25/07/2024.
//

import UIKit
import CountryPickerView

class PhoneVerifyVC: UIViewController {
  

    @IBOutlet weak var view_countryCode: CountryPickerView!
    
    @IBOutlet weak var tf_numberField: UITextField!
    @IBOutlet weak var lbl_CountryCode: UILabel!
    
    @IBOutlet weak var img_countryImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view_countryCode.delegate = self
//        view_countryCode.showPhoneCodeInView = false
//        view_countryCode.showCountryCodeInView = false
//        view_countryCode.showCountryNameInView = false
//        view_countryCode.flagImageView.isHidden = true
        
    }
    
    @IBAction func confirmBtnAction(_ sender: Any) {
    }
    
//    func countryPickerView(_ countryPickerView: CountryPickerView.CountryPickerView, didSelectCountry country: CountryPickerView.Country) {
//        
//         country.flag = self.img_countryImage.image
//        country.code = self.lbl_CountryCode.text
//    }
    
}
