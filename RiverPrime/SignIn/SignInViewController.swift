//
//  SignInViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//
import Foundation
import UIKit
import TPKeyboardAvoiding

class SignInViewController: UIViewController {

    @IBOutlet weak var username_tf: UITextField!{
        didSet{
            username_tf.setIcon(UIImage(systemName: "person.fill")!)
            username_tf.tintColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var password_tf: UITextField!{
        didSet{
            password_tf.tintColor = UIColor.lightGray
            password_tf.setIcon(UIImage(imageLiteralResourceName: "passwordIcon"))
        }
    }
    
    @IBOutlet weak var btn_rememberMe: UIButton!
    
    @IBOutlet weak var hideShowPassBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func rememberMeBtn(_ sender: Any) {
        self.btn_rememberMe.isSelected = !self.btn_rememberMe.isSelected
        self.btn_rememberMe.setImage(!self.btn_rememberMe.isSelected ? UIImage(systemName: "square") : UIImage(systemName: "checkmark.square"), for: .normal)
        
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        self.password_tf.isSecureTextEntry = !self.password_tf.isSecureTextEntry
        self.hideShowPassBtn.setImage(!self.password_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func submitBtn(_ sender: Any) {
    }
    
    
    
    @IBAction func forgotBtn(_ sender: Any) {
        if let forgotVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "ForgotViewController"){
            self.navigate(to: forgotVC)
        }
    }
    
    @IBAction func createAccountBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
