//
//  PhoneVerifyVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 25/07/2024.
//

import UIKit
import CountryPickerView
import PhoneNumberKit
import Firebase
import CoreLocation

class PhoneVerifyVC: BaseViewController, CLLocationManagerDelegate {
    @IBOutlet weak var view_countryCode: CountryPickerView!
    
    @IBOutlet weak var tf_numberField: UITextField!
    
    let locationManager = CLLocationManager()
    
    var number = ""
    var selectedCountry: Country?
    let phoneNumberKit = PhoneNumberKit()
    
    let userId =  UserDefaults.standard.string(forKey: "userID")
    var userEmail: String = ""
    let firestoreService = FirestoreServices()
    let oodoService = OdooClient()
    let oodoServiceNew = OdooClientNew()
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
//        oodoService.delegate = self
        oodoService.updateNumberDelegate = self
        oodoServiceNew.otpDelegate = self
        oodoServiceNew.updateNumberDelegate = self
        
        view_countryCode.delegate = self
        view_countryCode.showPhoneCodeInView = false
        view_countryCode.showCountryCodeInView = false
        view_countryCode.showCountryNameInView = false
        view_countryCode.flagImageView.isHidden = false
        
        tf_numberField.delegate = self
      
    }
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Show Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .white, barColor: .clear)
    }
    
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
                  
                  let country = self.view_countryCode.getCountryByCode(countryCode)
                  
                  // Access the flag and country code
                  if let currentCountry = country {
                      print("Country Flag: \(currentCountry.flag)")
                      print("Country Code: \(currentCountry.code)")
                      print("Country Phone Code: \(currentCountry.phoneCode)")
                      self.tf_numberField.text = currentCountry.phoneCode
                      self.view_countryCode.flagImageView.image = currentCountry.flag
                     
                      self.locationManager.stopUpdatingLocation()
                      // Optionally, you can update UI with this information
                      // Example: self.countryLabel.text = "\(currentCountry.flag) \(currentCountry.phoneCode)"
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
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        
        print("\(userId ?? "")")
        print(self.tf_numberField.text ?? "")
        guard let userId = userId, let selectedCountry = selectedCountry,
              let phoneNumber = tf_numberField.text, !phoneNumber.isEmpty else {
            print("Please enter your phone number")
            self.ToastMessage("Please enter your phone number")
            return
        }
        do {
            let phoneNumber1 = try phoneNumberKit.parse(phoneNumber, withRegion: selectedCountry.code, ignoreType: true)
                  let formattedNumber = phoneNumberKit.format(phoneNumber1, toType: .international)
            tf_numberField.text = formattedNumber
            UserDefaults.standard.set(tf_numberField.text, forKey: "phoneNumber")
            self.oodoService.writeRecords(number: self.tf_numberField.text ?? "") // update the CRM with user phoneNumber
            
              } catch {
                  showAlert(message: "Invalid phone number for the given country code")
            }
    }
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func navigateToVerifiyScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
       
        verifyVC.isEmailVerification = false
        verifyVC.isPhoneVerification = true
        verifyVC.userPhone = self.tf_numberField.text ?? "0000"
        self.navigate(to: verifyVC)
    }
    private func navigateToDashboardScreen() {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
        self.navigate(to: dashboardVC)
    }
    
}
// MARK: - delegate from phone number OTP
extension PhoneVerifyVC:  SendOTPDelegate {
    
    func otpSuccess(response: Any) {
        print("this is the phone send otp response: \(response)")
        navigateToVerifiyScreen()
    }
    
    func otpFailure(error: any Error) {
        print("this is the phone send otp error response: \(error)")
    }
}
// MARK: - delegate from update number Method on CRM
extension PhoneVerifyVC: UpdatePhoneNumebrDelegate {
    func updateNumberSuccess(response: Any) {
        print("the phone number update successfuly response is: \(response)")
        
        var number = self.tf_numberField.text!
 
        number = number.replacingOccurrences(of: " ", with: "")
        print("number is: \(number)")
//        oodoServiceNew.sendOTP(type: "phone", email: GlobalVariable.instance.userEmail, phone: number)
        navigateToDashboardScreen()
        
    }
    
    func updateNumberFailure(error: any Error) {
        print("this is the update phone number error response: \(error)")
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
