//
//  ForgotViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit
import FirebaseAuth

class ForgotViewController: BaseViewController {

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
            //print("saved User Data: \(savedUserData)")
            if let _email = savedUserData["email"] as? String {
                self.email_tf.text = _email
                email = _email
                print("saved User email: \(_email)")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func continue_btn(_ sender: Any) {

        if self.email_tf.text != "" {
             email = self.email_tf.text ?? ""
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    // Handle error
                    self.ToastMessage("Error: \(error.localizedDescription)")
                } else {
                    // Notify user that the reset email has been sent
                    self.showSimpleAlert("An email with a password reset link has been sent to the registered address.")
                }
            }
        }else{
            self.lbl_emailvalidation.isHidden = false
        }
    
    }
    
    @IBAction func backLoginBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true) 
    }
    
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
