//
//  ResidencVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/12/2024.
//

import UIKit
import CountryPickerView

class ResidencVC: UIViewController {
    @IBOutlet weak var view_nationailtyCountryPicker: CountryPickerView!
    @IBOutlet weak var view_residencyCountryPicker: CountryPickerView!

    @IBOutlet weak var tf_nationailityField: UITextField!
    @IBOutlet weak var tf_residencyField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view_nationailtyCountryPicker.delegate = self
        view_nationailtyCountryPicker.showPhoneCodeInView = false
        view_nationailtyCountryPicker.showCountryCodeInView = false
        view_nationailtyCountryPicker.showCountryNameInView = false
        view_nationailtyCountryPicker.flagImageView.isHidden = false
        
        view_residencyCountryPicker.delegate = self
        view_residencyCountryPicker.showPhoneCodeInView = false
        view_residencyCountryPicker.showCountryCodeInView = false
        view_residencyCountryPicker.showCountryNameInView = false
        view_residencyCountryPicker.flagImageView.isHidden = false
       
        
        
        self.tf_nationailityField.isEnabled = false
        self.tf_residencyField.isEnabled = false
        
        if let selectedCountry = CountryManager.shared.selectedCountry {
            self.tf_residencyField.text = selectedCountry.name
            self.view_residencyCountryPicker.flagImageView.image = selectedCountry.flag
        }
        
    }
    
    @IBAction func confirm_btnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "HomeTabbarViewController") as! HomeTabbarViewController
        self.navigate(to: dashboardVC)
    }
    
    
}
extension ResidencVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        if countryPickerView == view_nationailtyCountryPicker {
              // Update the nationality text field
            tf_nationailityField.text = country.name
//              self.tf_nationality.text = "\(country.flag) \(country.name)"
            self.view_nationailtyCountryPicker.flagImageView.image = country.flag
          } else if countryPickerView == view_residencyCountryPicker {
              // Update the residency text field
              tf_residencyField.text = country.name
//              self.tf_residency.text = "\(country.flag) \(country.name)"
              self.view_residencyCountryPicker.flagImageView.image = country.flag
          }
        
    }
    
    
}
