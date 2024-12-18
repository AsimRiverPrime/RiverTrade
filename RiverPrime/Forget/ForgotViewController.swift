//
//  ForgotViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit
import FirebaseAuth

class ForgotViewController: UIViewController {

    @IBOutlet weak var email_tf: UITextField!{
        didSet{
            email_tf.setIcon(UIImage(imageLiteralResourceName: "emailIcon"))
            email_tf.tintColor = UIColor.lightGray
        }
    }
    @IBOutlet weak var lbl_emailvalidation: UILabel!
    
    var email = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lbl_emailvalidation.isHidden = true
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            if let _email = savedUserData["email"] as? String {
                self.email_tf.text = _email
                email = _email
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func continue_btn(_ sender: Any) {

        if self.email_tf.text != "" {
            self.email_tf.text = email
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    // Handle error
                    self.showSimpleAlert("Error: \(error.localizedDescription)")
                } else {
                    // Notify user that the reset email has been sent
                    self.showSimpleAlert("Password reset email sent.Please check your inbox!")
                }
            }
        }else{
            self.lbl_emailvalidation.isHidden = false
        }
    
    }
    
    @IBAction func backLoginBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true) 
    }
    
    // Function to show alert with a text field for the email
//       func showAlertWithEmailField() {
//           let alert = UIAlertController(title: "Reset Password", message: "Enter your email address to reset your password.", preferredStyle: .alert)
//           
//           // Add a text field to the alert for email input
//           alert.addTextField { textField in
//               textField.placeholder = "Enter your email"
//               textField.keyboardType = .emailAddress
//           }
//           
//           // Add a "Send" action that triggers password reset
//           let sendAction = UIAlertAction(title: "Send", style: .default) { _ in
//               if let email = alert.textFields?.first?.text, !email.isEmpty {
//                   // Send password reset email
//                   Auth.auth().sendPasswordReset(withEmail: email) { error in
//                       if let error = error {
//                           // Handle error
//                           self.showSimpleAlert("Error: \(error.localizedDescription)")
//                       } else {
//                           // Notify user that the reset email has been sent
//                           self.showSimpleAlert("Password reset email sent. Check your inbox!")
//                       }
//                   }
//               } else {
//                   // Show error if email is empty
//                   self.showSimpleAlert("Please enter a valid email address.")
//               }
//           }
//           
//           // Add a cancel action
//           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//           
//           // Add actions to the alert
//           alert.addAction(sendAction)
//           alert.addAction(cancelAction)
//           
//           // Present the alert
//           present(alert, animated: true, completion: nil)
//       }
       
       // Helper function to show a simple alert message
       func showSimpleAlert(_ message: String) {
           let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
               // Pop the current view controller to go back
               self.navigationController?.popViewController(animated: true)
           }))
           present(alert, animated: true, completion: nil)
       }
}
