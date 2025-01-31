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
        @IBOutlet weak var lbl_checkNationality: UILabel!
    
        @IBOutlet weak var btn_confirm: CardViewButton!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view_nationailtyCountryPicker.delegate = self
            view_nationailtyCountryPicker.showPhoneCodeInView = false
            view_nationailtyCountryPicker.showCountryCodeInView = false
            view_nationailtyCountryPicker.showCountryNameInView = false
            view_nationailtyCountryPicker.flagImageView.isHidden = false
            
            

           
            self.btn_confirm.isUserInteractionEnabled = false
            self.btn_confirm.tintColor = .systemGray
            self.btn_confirm.layer.borderColor =   UIColor.systemGray.cgColor
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkNationality_action))
            lbl_checkNationality.addGestureRecognizer(tapGesture)
            
            let tapGestureTextfield = UITapGestureRecognizer(target: self, action: #selector(showCountryPicker))
            tf_nationailityField.addGestureRecognizer(tapGestureTextfield)
            self.tf_nationailityField.isUserInteractionEnabled = true
        }
    
    @objc func showCountryPicker() {
        tf_nationailityField.resignFirstResponder() // Dismiss the keyboard if needed
        view_nationailtyCountryPicker.showCountriesList(from: self) // Show the picker
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: ViewController(), navController: self.navigationController, title: "Nationality", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
        @IBAction func checkNationality_action(_ sender: Any) {
            self.btn_NationalityCheck.isSelected = !self.btn_NationalityCheck.isSelected
            self.btn_NationalityCheck.setImage(!self.btn_NationalityCheck.isSelected ? UIImage(systemName: "square")?.withTintColor(.white) : UIImage(systemName: "checkmark.square")?.withTintColor(.systemYellow), for: .normal)
           
            if self.btn_NationalityCheck.isSelected {
                self.btn_confirm.isUserInteractionEnabled = true
                self.btn_confirm.tintColor = .systemYellow
                self.btn_confirm.layer.borderColor =   UIColor.systemYellow.cgColor

            }else{
                self.btn_confirm.isUserInteractionEnabled = false
                self.btn_confirm.tintColor = .systemGray
                self.btn_confirm.layer.borderColor =   UIColor.systemGray.cgColor

            }
            
        }
        
    func blinkLabelColor(label: UILabel, toColor: UIColor, originalColor: UIColor) {
        // Change to red color
        UIView.animate(withDuration: 0.5, animations: {
            label.textColor = toColor
        }) { _ in
            // Revert to the original color after 1 second
            UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                label.textColor = originalColor
            })
        }
    }
    
    @IBAction func confirm_btnAction(_ sender: Any) {
        if !self.btn_NationalityCheck.isSelected {
            ToastMessage("enable declear check.")
            blinkLabelColor(label: lbl_checkNationality, toColor: .systemRed, originalColor: .white)

            return
        }
        
        guard let _national = tf_nationailityField.text, !_national.isEmpty else {
        ToastMessage("Select nationality country first")
            return
        }
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let residencVC = storyboard.instantiateViewController(withIdentifier: "ResidencVC") as! ResidencVC
            residencVC.nationality = tf_nationailityField.text ?? ""
            self.navigate(to: residencVC)
     
    }
}

extension NationalityVC: CountryPickerViewDelegate {
        func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
           
                tf_nationailityField.text = country.name
                self.view_nationailtyCountryPicker.flagImageView.image = country.flag
            GlobalVariable.instance.nationality = tf_nationailityField.text ?? ""
            }
        
    }
