//
//  PasscodeFaceIDVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 22/08/2024.
//

import UIKit
import LocalAuthentication


class PasscodeFaceIDVC: UIViewController {
    
    @IBOutlet weak var lbl_enterCode: UILabel!
    
    @IBOutlet var view_dots: [UIView]!
    
    @IBOutlet var numbers_btn: [UIButton]!
    @IBOutlet weak var btn_faceID: UIButton!
    @IBOutlet weak var btn_forgot: UIButton!
    
    var enteredPasscode = ""
  //  var iscodeSelected : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateWithFaceID()
        updateFaceIDButtonAction()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func numberBtn_action(_ sender: Any) {
        handleNumberInput((sender as AnyObject).tag)
    }
    
    @IBAction func forgot_btnAction(_ sender: Any) {
    }
    
    @IBAction func faceID_action(_ sender: Any) {
        if !enteredPasscode.isEmpty  {
            // code for backspace
            backspaceAction()
        } else {
            enableFaceID()
        }
    }
    
    func handleNumberInput(_ tag: Int) {
        
        // Append the number to the enteredPasscode string
        enteredPasscode += "\(tag)"
        
        updateFaceIDButtonAction()
        // Update the dot color for the entered digit
        updateDots()
        
        // Check if the passcode length is 4 digits
        if enteredPasscode.count == 4 {
            // Check if a passcode is already saved in UserDefaults
            if UserDefaults.standard.string(forKey: "correctPasscode") == nil {
                // Save the new passcode
                savePasscode(enteredPasscode)
                print("Passcode saved successfully.")
                // Optionally, navigate to the main screen or provide feedback
                self.navigateToMainScreen()
            } else {
                // Verify the entered passcode
                verifyPasscode()
            }
        }
    }
    
    func backspaceAction() {
        if !enteredPasscode.isEmpty {
            enteredPasscode.removeLast()
            updateDots()
            updateFaceIDButtonAction()
        }
    }
    
    func updateFaceIDButtonAction() {
        if enteredPasscode.isEmpty {
            self.btn_faceID.setImage(UIImage(systemName: "faceid"), for: .normal)
        } else {
         
            self.btn_faceID.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        }
    }
    
    func updateDots() {
        for i in 0..<view_dots.count {
            if i < enteredPasscode.count {
                view_dots[i].backgroundColor = UIColor.systemYellow // Color when digit is entered
            } else {
                view_dots[i].backgroundColor = UIColor.systemGray5 // Default color
            }
        }
    }
    
    func verifyPasscode() {
        // Retrieve the correct passcode from UserDefaults
        if let correctPasscode = UserDefaults.standard.string(forKey: "correctPasscode") {
            if enteredPasscode == correctPasscode {
                print("Passcode correct!")
                self.navigateToMainScreen()
                // Navigate to the next screen or unlock content
            } else {
                print("Incorrect passcode.")
                // Reset enteredPasscode and dot colors
                enteredPasscode = ""
                resetDots()
                updateFaceIDButtonAction()
                //                showAlert("Passcode is inncorrect")
                Alert.showAlert(withMessage: "Passcode is incorrect", andTitle: "Invalid", on: self)
            }
        } else {
            print("No passcode set.")
            // Handle the case where no passcode is saved
        }
    }
    
    func resetDots() {
        for dot in view_dots {
            dot.backgroundColor = UIColor.systemGray5
        }
    }
    
    func savePasscode(_ passcode: String) {
        UserDefaults.standard.set(passcode, forKey: "correctPasscode")
    }
}

// MARK: - Face ID methods
extension PasscodeFaceIDVC {
    func enableFaceID() {
        let context = LAContext()
        var error: NSError?
        
        // Check if Face ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Request Face ID authentication
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable Face ID to login automatically") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Face ID enabled successfully, save the preference
                        UserDefaults.standard.set(true, forKey: "isFaceIDEnabled")
                        // Navigate to the main screen or do any post-authentication tasks
                        
                        for dot in self.view_dots {
                            dot.backgroundColor = UIColor.systemYellow // Color indicating success
                        }
                        
                        self.navigateToMainScreen()
                    } else {
                        // Handle the error, maybe show an alert
                        self.showAlert("Face ID authentication failed.")
                    }
                }
            }
        } else {
            // Face ID not available, handle accordingly
            self.showAlert("Face ID is not available on this device.")
        }
    }
    
    func authenticateWithFaceID() {
        let isFaceIDEnabled = UserDefaults.standard.bool(forKey: "isFaceIDEnabled")
        
        if isFaceIDEnabled {
            let context = LAContext()
            var error: NSError?
            
            // Check if Face ID is available
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                // Authenticate using Face ID
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in with Face ID") { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            // Authentication successful, navigate to the main screen
                            for dot in self.view_dots {
                                dot.backgroundColor = UIColor.systemYellow // Color indicating success
                            }
                            
                            self.navigateToMainScreen()
                        } else {
                            // Handle the error, maybe show an alert
                            self.showAlert("Face ID authentication failed.")
                        }
                    }
                }
            } else {
                // Face ID not available, handle accordingly
                self.showAlert("Face ID is not available on this device.")
            }
        }
    }
    func navigateToMainScreen() {
        // Implement the navigation to the main screen
        print("Go to the desire screen")
        if let dashboardVC = self.instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
            self.navigate(to: dashboardVC)
        }
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
