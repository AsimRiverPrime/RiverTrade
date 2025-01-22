//
//  ResidencVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/12/2024.
//

import UIKit
import CountryPickerView
import CoreLocation


class ResidencVC: BaseViewController {
    @IBOutlet weak var view_residencyCountryPicker: CountryPickerView!

//    @IBOutlet weak var flagImageView: UIView!
    @IBOutlet weak var btn_residenceCheck: UIButton!
    @IBOutlet weak var tf_residencyField: UITextField!
    @IBOutlet weak var btn_confirm: CardViewButton!
    @IBOutlet weak var lbl_checkResidence: UILabel!
    
   
    let locationManager = CLLocationManager()
    
    
    var fireStoreInstance = FirestoreServices()
    let userId =  UserDefaults.standard.string(forKey: "userID")
    var nationality = String()
    
    var isOpenAccount = Bool()
//    var isGoogleAccount = Bool()
//    var isAppleLogin = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isOpenAccount =  UserDefaults.standard.bool(forKey: "fromOpenAccount")

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        view_residencyCountryPicker.delegate = self
        view_residencyCountryPicker.showPhoneCodeInView = false
        view_residencyCountryPicker.showCountryCodeInView = false
        view_residencyCountryPicker.showCountryNameInView = false
        view_residencyCountryPicker.flagImageView.isHidden = false
       
//        odoClientNew.createLeadDelegate = self
//        self.googleSignIn.odoClientNew.createLeadDelegate = self

       
        self.btn_confirm.isUserInteractionEnabled = false
        self.btn_confirm.tintColor = .systemGray
        self.btn_confirm.layer.borderColor =   UIColor.systemGray.cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkResidence_action))
        lbl_checkResidence.addGestureRecognizer(tapGesture)
       
        let tapGestureTextfield = UITapGestureRecognizer(target: self, action: #selector(showCountryPicker))
        tf_residencyField.addGestureRecognizer(tapGestureTextfield)
        self.tf_residencyField.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
       
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: NationalityVC(), navController: self.navigationController, title: "Residence", leftTitle: "", rightTitle: "", textColor: .white, barColor: .clear)
    }
    
    @objc func showCountryPicker() {
        tf_residencyField.resignFirstResponder() // Dismiss the keyboard if needed
        view_residencyCountryPicker.showCountriesList(from: self) // Show the picker
    }
  
    @IBAction func checkResidence_action(_ sender: Any) {
        self.btn_residenceCheck.isSelected = !self.btn_residenceCheck.isSelected
        self.btn_residenceCheck.setImage(!self.btn_residenceCheck.isSelected ? UIImage(systemName: "square")?.withTintColor(.white) : UIImage(systemName: "checkmark.square")?.withTintColor(.systemYellow), for: .normal)
       
        if self.btn_residenceCheck.isSelected {
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
        if !self.btn_residenceCheck.isSelected {
            ToastMessage("enable declear check.")
            blinkLabelColor(label: lbl_checkResidence, toColor: .systemRed, originalColor: .white)

            return
        }
        
        guard let _residence = tf_residencyField.text, !_residence.isEmpty else {
        ToastMessage("Select residence country first")
            return
        }
                
        if isOpenAccount {
            navigateTologin()
        }else{
            navigateToPassword()
        }
    }
    
    func navigateTologin(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "EmailVC") as! EmailVC
        self.navigate(to: dashboardVC)
    }
    
    func navigateToPassword(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let passwordVC = storyboard.instantiateViewController(withIdentifier: "PasswordVC") as! PasswordVC
        
//        if isGoogleAccount{
//            passwordVC.googleUser = googleUser
//           
//        }
//        passwordVC.isOpenAccount = isOpenAccount
//        passwordVC.isAppleLogin = isAppleLogin
//        passwordVC.isGoogleAccount = isGoogleAccount
        
        self.navigate(to: passwordVC)
    }
    
    func navigateFaceID(){
        
        let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
        faceIdVC.afterLoginNavigation = false
        self.navigate(to: faceIdVC)
    }
    
    func navigateToVerifiyScreen() {
        
        let verifyOTP = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! VerifyCodeViewController
       
        self.navigate(to: verifyOTP)
    }
    
    
}

extension ResidencVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
      
            tf_residencyField.text = country.name
            self.view_residencyCountryPicker.flagImageView.image = country.flag
        GlobalVariable.instance.residence = tf_residencyField.text ?? ""
        
    }
}

extension ResidencVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           if let location = locations.first {
               // Reverse geocode to get the country code
               getCountryFromLocation(location)
           }
       }
    
    func getCountryFromLocation(_ location: CLLocation) {
          let geocoder = CLGeocoder()
          
          geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
              if let error = error {
                  print("Failed to reverse geocode: \(error.localizedDescription)")
                  return
              }
              
              if let placemark = placemarks?.first, let countryCode = placemark.isoCountryCode {
                  
                  let country = self.view_residencyCountryPicker.getCountryByCode(countryCode)
                  
                  // Access the flag and country code
                  if let currentCountry = country {
                      CountryManager.shared.selectedCountry = currentCountry
                      print("Country Flag: \(currentCountry.flag)")
                      print("Country Code: \(currentCountry.code)")
                      print("Country Phone Code: \(currentCountry.phoneCode)")
                  
                      self.view_residencyCountryPicker.flagImageView.image = currentCountry.flag
                      self.tf_residencyField.text = currentCountry.name
                      
                      self.locationManager.stopUpdatingLocation()
                      
                  }
              }
          }
      }
      
      // Handle location authorization changes
      func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
          if status == .authorizedWhenInUse || status == .authorizedAlways {
              locationManager.startUpdatingLocation()
          } else {
              print("Location access denied")
          }
      }

      // Handle location errors
      func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          print("Failed to get location: \(error.localizedDescription)")
      }
}

class CountryManager {
    static let shared = CountryManager()
    var selectedCountry: Country?

    private init() {} // Prevent initialization from outside
}

