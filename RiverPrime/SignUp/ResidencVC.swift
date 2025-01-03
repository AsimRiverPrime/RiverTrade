//
//  ResidencVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/12/2024.
//

import UIKit
import CountryPickerView

class ResidencVC: BaseViewController {
    @IBOutlet weak var view_residencyCountryPicker: CountryPickerView!

    @IBOutlet weak var btn_residenceCheck: UIButton!
    @IBOutlet weak var tf_residencyField: UITextField!
    @IBOutlet weak var btn_confirm: CardViewButton!
    
    var fireStoreInstance = FirestoreServices()
    let userId =  UserDefaults.standard.string(forKey: "userID")
    var nationality = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view_residencyCountryPicker.delegate = self
        view_residencyCountryPicker.showPhoneCodeInView = false
        view_residencyCountryPicker.showCountryCodeInView = false
        view_residencyCountryPicker.showCountryNameInView = false
        view_residencyCountryPicker.flagImageView.isHidden = false
       
        
        self.tf_residencyField.isEnabled = false
        
        if let selectedCountry = CountryManager.shared.selectedCountry {
            self.tf_residencyField.text = selectedCountry.name
            self.view_residencyCountryPicker.flagImageView.image = selectedCountry.flag
        }
         
    }
    
    @IBAction func checkResidence_action(_ sender: Any) {
        self.btn_residenceCheck.isSelected = !self.btn_residenceCheck.isSelected
        self.btn_residenceCheck.setImage(!self.btn_residenceCheck.isSelected ? UIImage(systemName: "square")?.withTintColor(.white) : UIImage(systemName: "checkmark.square")?.withTintColor(.systemYellow), for: .normal)
       
        if self.btn_residenceCheck.isSelected {
            self.btn_confirm.isUserInteractionEnabled = true
            self.btn_confirm.tintColor = .systemYellow
        }else{
            self.btn_confirm.isUserInteractionEnabled = false
            self.btn_confirm.tintColor = .systemGray
        }
        
    }
    
    @IBAction func confirm_btnAction(_ sender: Any) {
        if !self.btn_residenceCheck.isSelected {
            self.showTimeAlert(str: "Select country first")
            return
        } else if tf_residencyField.text != "" {
            updateUser()
        }else{
            self.showTimeAlert(str: "Select your Nationality")
        }
        
       
    }
    
    func navigateDashboard(){
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "HomeTabbarViewController") as! HomeTabbarViewController
        self.navigate(to: dashboardVC)
        
//        let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
//        self.navigate(to: faceIdVC)
    }
    
    func updateUser(){
        
        guard let userId = userId else{
            return
        }
        var fieldsToUpdate: [String: Any] = [:]
       
            fieldsToUpdate = [
                "residence": self.tf_residencyField.text ?? "",
                "nationality" : self.nationality
            ]
         
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                self.fireStoreInstance.fetchUserData(userId: userId)
                self.navigateDashboard()
                }
        }
    }
    
}

extension ResidencVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
      
            tf_residencyField.text = country.name
            self.view_residencyCountryPicker.flagImageView.image = country.flag
        
    }
}
