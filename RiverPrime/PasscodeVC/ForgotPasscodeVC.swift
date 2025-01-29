//
//  ForgotPasscodeVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/08/2024.
//

import UIKit

class ForgotPasscodeVC: BaseViewController {
    
    @IBOutlet weak var lbl_setPasscode: UILabel!
    
    @IBOutlet var view_dots: [UIView]!
    
    @IBOutlet var numbers_btn: [UIButton]!
    
    var enteredPasscode = ""
    
    var reEnterPass : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .darkGray, barColor: .black)
    }
    
    
    @IBAction func numberBtn_action(_ sender: Any) {
        handleNumberInput((sender as AnyObject).tag)
    }
    
    @IBAction func backSpace_action(_ sender: Any) {
        if !enteredPasscode.isEmpty  {
            // code for backspace
            backspaceAction()
        }else{
            print("the fields is already empty")
        }
    }
    
    func handleNumberInput(_ tag: Int) {
        if reEnterPass ==  true {
            enteredPasscode += "\(tag)"
            updateDots()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.enteredPasscode.count == 4 {
                    // Check if a passcode is already saved in UserDefaults
                    if UserDefaults.standard.string(forKey: "correctPasscode") == nil {
                        // Save the new passcode
                        self.savePasscode(self.enteredPasscode)
                        print("Passcode saved successfully.")
                        
                    }else{
                        self.verifyPasscode()
                    }
                }else{
                    
                }
            }
        }else{
            enteredPasscode += "\(tag)"
            updateDots()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.enteredPasscode.count == 4 {
                    
                    // Save the new passcode
                    self.savePasscode(self.enteredPasscode)
                    self.reTypeMethod()
                }else{
                    
                }
            }
        }
    }
    
    func  reTypeMethod() {
        enteredPasscode = ""
        resetDots()
        updateDots()
        reEnterPass = true
        lbl_setPasscode.text = "Re-Type the Passcode"
    }
    
    func backspaceAction() {
        if !enteredPasscode.isEmpty {
            enteredPasscode.removeLast()
            updateDots()
           
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
        // Retrieve the correct passcode from UserDefaults // Re-Enter passcode check
        if let correctPasscode = UserDefaults.standard.string(forKey: "correctPasscode") {
            if enteredPasscode == correctPasscode {
                print("Passcode match and verified correct!")
                reEnterPass = false
                self.navigateToPassCodeScreen()
                // Navigate to the next screen or unlock content
                
            } else {
                print("Incorrect passcode.")
                // Reset enteredPasscode and dot colors
                enteredPasscode = ""
                resetDots()
                
                Alert.showAlert(withMessage: "Passcode is not match", andTitle: "Invalid", on: self)
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
    
    func navigateToPassCodeScreen() {
        // Implement the navigation to the main screen
        print("Go to the Passcode screen")

        self.navigationController?.popViewController(animated: true)
    }
}
