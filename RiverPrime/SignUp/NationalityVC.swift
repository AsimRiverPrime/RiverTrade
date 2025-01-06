//
//  NationalityVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 02/01/2025.
//

import UIKit
import CountryPickerView

class NationalityVC: BaseViewController {
        @IBOutlet weak var view_nationailtyCountryPicker: CountryPickerView!

        @IBOutlet weak var btn_NationalityCheck: UIButton!
        @IBOutlet weak var tf_nationailityField: UITextField!
    
        @IBOutlet weak var btn_confirm: CardViewButton!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view_nationailtyCountryPicker.delegate = self
            view_nationailtyCountryPicker.showPhoneCodeInView = false
            view_nationailtyCountryPicker.showCountryCodeInView = false
            view_nationailtyCountryPicker.showCountryNameInView = false
            view_nationailtyCountryPicker.flagImageView.isHidden = false
            
            
            self.btn_confirm.isUserInteractionEnabled = false
            self.tf_nationailityField.isEnabled = false
          
        }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: ViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .white, barColor: .clear)
    }
        @IBAction func checkNationality_action(_ sender: Any) {
            self.btn_NationalityCheck.isSelected = !self.btn_NationalityCheck.isSelected
            self.btn_NationalityCheck.setImage(!self.btn_NationalityCheck.isSelected ? UIImage(systemName: "square")?.withTintColor(.white) : UIImage(systemName: "checkmark.square")?.withTintColor(.systemYellow), for: .normal)
           
            if self.btn_NationalityCheck.isSelected {
                self.btn_confirm.isUserInteractionEnabled = true
                self.btn_confirm.tintColor = .systemYellow
            }else{
                self.btn_confirm.isUserInteractionEnabled = false
                self.btn_confirm.tintColor = .systemGray
            }
            
        }
        
        
    @IBAction func confirm_btnAction(_ sender: Any) {
//        if !self.btn_NationalityCheck.isSelected {
//            self.showTimeAlert(str: "please Select check first")
//            return
//        } else if tf_nationailityField.text != "" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let residencVC = storyboard.instantiateViewController(withIdentifier: "ResidencVC") as! ResidencVC
            residencVC.nationality = tf_nationailityField.text ?? ""
            self.navigate(to: residencVC)
//        }else{
//            self.showTimeAlert(str: "Select your Nationality")
//        }
    }
}

extension NationalityVC: CountryPickerViewDelegate {
        func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
           
                tf_nationailityField.text = country.name
                self.view_nationailtyCountryPicker.flagImageView.image = country.flag
            }
        
    }
