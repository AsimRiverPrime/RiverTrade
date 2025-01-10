//
//  EmailVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/01/2025.
//

import UIKit

class EmailVC: BaseViewController {

   
    @IBOutlet weak var tf_email: UITextField!{
        didSet{
            tf_email.setIcon(UIImage(imageLiteralResourceName: "emailIcon"))
            tf_email.tintColor = UIColor.lightGray
        }
    }
    @IBOutlet weak var lbl_emailError: UILabel!
    
    var viewModel = SignViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tf_email.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func emailTextChanged(_ textField: UITextField) {
        if self.viewModel.isValidEmail(self.tf_email.text!)  {
            self.lbl_emailError.isHidden = true
           
        } else {
            self.lbl_emailError.textColor = .systemRed
            self.lbl_emailError.text = "Email is not correct"
            self.lbl_emailError.isHidden = false
        }
        
    }
    
    @IBAction func continue_action(_ sender: Any) {

        
        guard let email = tf_email.text, !email.isEmpty else {
            self.lbl_emailError.isHidden = false
            self.lbl_emailError.text = "This field cannot be empty"
            return
        }
        
        if let passwordVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "PasswordVC") as? PasswordVC {
            passwordVC.email = tf_email.text
          
            self.navigate(to: passwordVC)
        }
    }
    
}
