//
//  SignUpViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//
import Foundation
import UIKit
import TPKeyboardAvoiding

class SignUpViewController: UIViewController {

    @IBOutlet weak var lbl_firstName: UITextField!
    @IBOutlet weak var lbl_lastName: UITextField!
    
    @IBOutlet weak var lbl_emailValid: UILabel!
    @IBOutlet weak var lbl_passValid: UILabel!

    @IBOutlet weak var userName_tf: UITextField! {
           didSet{
               userName_tf.setIcon(UIImage(systemName: "person.fill")!)
               userName_tf.tintColor = UIColor.lightGray
           }
       }
       @IBOutlet weak var email_tf: UITextField!{
           didSet{
               email_tf.setIcon(UIImage(imageLiteralResourceName: "emailIcon"))
               email_tf.tintColor = UIColor.lightGray
           }
       }
       
       @IBOutlet weak var password_tf: UITextField!{
           didSet{
               password_tf.tintColor = UIColor.lightGray
               password_tf.setIcon(UIImage(imageLiteralResourceName: "passwordIcon"))
           }
       }
       
       @IBOutlet weak var btn_termsCondition: UIButton!
       @IBOutlet weak var btn_passowrdIcon: UIButton!
    
    @IBOutlet weak var btn_contiune: UIButton!

    var viewModel: SignViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.email_tf.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
        self.password_tf.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    @objc func emailTextChanged(_ textField: UITextField) {
          if self.viewModel?.isValidEmail(textField.text!) ?? false {
              self.lbl_emailValid.isHidden = true
          } else {
              self.lbl_emailValid.textColor = .red
              self.lbl_emailValid.isHidden = false
          }
          self.enableLoginButton()
      }
      
      @objc func passwordTextChanged(_ textField: UITextField) {
          
          if self.viewModel?.isPasswordValid(password: self.password_tf.text!) ?? false {
              self.lbl_passValid.isHidden = true
              
          } else {
              self.lbl_passValid.isHidden = false
              self.lbl_passValid.text = "Enter a valid Password"
              self.lbl_passValid.textColor = .red
          }
          self.enableLoginButton()
      }
      
      private func enableLoginButton() {
          if self.viewModel?.isLoginFieldsValid(email: self.email_tf.text!, password: self.password_tf.text!) ?? false {
              self.btn_contiune.isEnabled = true
//              loginBtn.setTitleColor(UIColor(named: "lightblueColor"), for: .normal)
          } else {
              self.btn_contiune.isEnabled = false
          }
      }
      
    
    @IBAction func signInBtn(_ sender: Any) {
        if let signInVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignInViewController"){
            self.navigate(to: signInVC)
        }
    }
    
    @IBAction func termsConditionBtn(_ sender: Any) {
        self.btn_termsCondition.isSelected = !self.btn_termsCondition.isSelected
        self.btn_termsCondition.setImage(!self.btn_termsCondition.isSelected ? UIImage(systemName: "square") : UIImage(systemName: "checkmark.square"), for: .normal)
    }
    
    @IBAction func continueBtn(_ sender: Any) {
//        if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "HomeTabbarViewController"){
        if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
            self.navigate(to: dashboardVC)
        }
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        self.password_tf.isSecureTextEntry = !self.password_tf.isSecureTextEntry
        self.btn_passowrdIcon.setImage(!self.password_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func continueGoogleBtn(_ sender: Any) {
        
    }
    
    @IBAction func termConditionBtn(_ sender: Any) {
        if let termConditionVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "TermsConditionsViewController") {
            self.navigate(to: termConditionVC)
        }
        
    }
    @IBAction func privacyPolicyBtn(_ sender: Any) {
        if let privcyVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "PrivacyViewController")  {
            self.navigate(to: privcyVC)
        }
    }
    
}
