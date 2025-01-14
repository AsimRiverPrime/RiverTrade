//
//  FaceIDAlertView.swift
//  RiverPrime
//
//  Created by Ross Rostane on 04/01/2025.
//

import UIKit
import LocalAuthentication

class FaceIDAlertView: UIView {
    
//    @IBOutlet weak var lbl_enterCode: UILabel!
//    @IBOutlet var view_dots: [UIView]!
    
//    @IBOutlet var numbers_btn: [UIButton]!
//    @IBOutlet weak var btn_faceID: UIButton!
//    @IBOutlet weak var btn_forgot: UIButton!
    
    @IBOutlet weak var lbl_enterCode: UILabel!
    @IBOutlet var view_dots: [UIView]!
    @IBOutlet weak var btn_faceID: UIButton!
    @IBOutlet weak var btn_forgot: UIButton!
    
    var enteredPasscode = ""
    //  var iscodeSelected : Bool = false
    let isFaceIDEnabled = UserDefaults.standard.bool(forKey: "isFaceIDEnabled")
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        authenticateWithFaceID()
        updateFaceIDButtonAction()
        // Do any additional setup after loading the view.
    }
    
    class func getView()->FaceIDAlertView {
        return Bundle.main.loadNibNamed("FaceIDAlertView", owner: self, options: nil)?.first as! FaceIDAlertView
    }
    
    func dismissView() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0.04,
            animations: {
                self.alpha = 0
            }, completion: { (complete) in
                self.removeFromSuperview()
            })
    }
    
    @IBAction func numberBtn_action1(_ sender: Any) {
        handleNumberInput((sender as AnyObject).tag)
    }
    @IBAction func numberBtn_action(_ sender: UIButton) {
        handleNumberInput((sender as AnyObject).tag)
    }
    
//    @IBAction func forgot_btnAction(_ sender: Any) {
////        if let vc = instantiateViewController(fromStoryboard: "Main", withIdentifier: "ForgotPasscodeVC") {
////            self.navigate(to: vc)
////        }
//    }
    @IBAction func forgot_btnAction(_ sender: UIButton) {
    }
    
    @IBAction func faceID_action1(_ sender: Any) {
        if !enteredPasscode.isEmpty  {
            // code for backspace
            backspaceAction()
        } else {
           enableFaceID()
        }
    }
    @IBAction func faceID_action(_ sender: UIButton) {
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
        print("/nPasscode number is.\(enteredPasscode)")
        // Check if the passcode length is 4 digits
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.enteredPasscode.count == 4 {
                // Check if a passcode is already saved in UserDefaults
                if UserDefaults.standard.string(forKey: "correctPasscode") == nil {
                    // Save the new passcode
                    self.savePasscode(self.enteredPasscode)
                    print("Passcode saved successfully.")
                    // Optionally, navigate to the main screen or provide feedback
//                     self.navigateToMainScreen()
                    
                    Alert.ShowWindowAlert("Allow Face ID to unlock River Trade App.", andTitle: "Face ID", OKButtonText: "Continue", window: SCENE_DELEGATE.window!) { ok in
                        self.enableFaceID()
                    } andCompletionHandler: { cancel in
                        print("Cancel")
                    }

                    
//                    Alert.showAlertWithOKHandler(withHandler: "Allow Face ID to unlock River Trade App.", andTitle: "Face ID", OKButtonText: "Continue", on: self) { action in
//                        self.enableFaceID()
//                    }
                } else {
                    // Verify the entered passcode
                    self.verifyPasscode()
                }
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
                
//                Alert.showAlert(withMessage: "Passcode is incorrect", andTitle: "Invalid", on: self)
                
                Alert.ShowWindowAlert("Passcode is incorrect", andTitle: "Invalid", window: SCENE_DELEGATE.window!) { ok in
//                    self.enableFaceID()
                } andCompletionHandler: { cancel in
                    print("Cancel")
                }
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
extension FaceIDAlertView {
    func enableFaceID() {
       
        if !isFaceIDEnabled {
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
                            Session.instance.isFaceIDEnabled = true
                            // Navigate to the main screen or do any post-authentication tasks
                            
                            for dot in self.view_dots {
                                dot.backgroundColor = UIColor.systemYellow // Color indicating success
                            }
                            
                            self.navigateToMainScreen()
                        } else {
                            // Handle the error, maybe show an alert
//                            Alert.showAlert(withMessage: "Face ID authentication failed.", andTitle: "Invalid", on: self)
                            
                            Alert.ShowWindowAlert("Face ID authentication failed.", andTitle: "Invalid", window: SCENE_DELEGATE.window!) { ok in
            //                    self.enableFaceID()
                            } andCompletionHandler: { cancel in
                                print("Cancel")
                            }
                        }
                    }
                }
            } else {
                // Face ID not available, handle accordingly
//                Alert.showAlert(withMessage: "Face ID is not available on this device.", andTitle: "Invalid", on: self)
                
                Alert.ShowWindowAlert("Face ID is not available on this device.", andTitle: "Invalid", window: SCENE_DELEGATE.window!) { ok in
//                    self.enableFaceID()
                } andCompletionHandler: { cancel in
                    print("Cancel")
                }
            }
        }else{
            authenticateWithFaceID()
        }
    }
    
    
    func authenticateWithFaceID() {
       
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
                            Session.instance.isFaceIDEnabled = true
                            self.navigateToMainScreen()
                        } else {
                            // Handle the error, maybe show an alert
                            
//                            Alert.showAlert(withMessage: "Face ID authentication failed.", andTitle: "Invalid", on: self)
                            
                            Alert.ShowWindowAlert("Face ID authentication failed.", andTitle: "Invalid", window: SCENE_DELEGATE.window!) { ok in
            //                    self.enableFaceID()
                            } andCompletionHandler: { cancel in
                                print("Cancel")
                            }
                        }
                    }
                }
            } else {
                // Face ID not available, handle accordingly
                
//                Alert.showAlert(withMessage: "Face ID is not available on this device.", andTitle: "Invalid", on: self)
                
                Alert.ShowWindowAlert("Face ID is not available on this device.", andTitle: "Invalid", window: SCENE_DELEGATE.window!) { ok in
//                    self.enableFaceID()
                } andCompletionHandler: { cancel in
                    print("Cancel")
                }
            }
        }
    }
    
    func navigateToMainScreen() {
        // Implement the navigation to the main screen
//        if GlobalVariable.instance.isAppBecomeActive {
//            GlobalVariable.instance.isAppBecomeActive = false
//            self.navigationController?.popViewController(animated: true)
//        }else{
            print("Go to the desire screen")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//               
//                if let dashboardVC = self.instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "HomeTabbarViewController"){
//                    self.navigate(to: dashboardVC)
//                }
////                self.navigationController?.dismiss(animated: true, completion: nil)
//                
//        }
        
        self.dismissView()
    }
 
}

