//
//  LoginPopupVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/10/2024.
//

import UIKit

class LoginPopupVC: UIViewController {

    @IBOutlet weak var login_popupView: UIView!
    
    @IBOutlet weak var loginID_tf: UITextField!{
        didSet{
            loginID_tf.setIcon(UIImage(systemName: "iphone.and.arrow.forward.outward")!)
            loginID_tf.tintColor = UIColor.darkGray
        }
    }
    
    @IBOutlet weak var password_tf: UITextField!{
        didSet{
            password_tf.tintColor = UIColor.darkGray
            password_tf.setIcon(UIImage(imageLiteralResourceName: "passwordIcon"))
        }
    }
    @IBOutlet weak var Btn_showHidePass: UIButton!
    
    var email: String?
    var loginId: Int?
    
    var viewModel = TradeTypeCellVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String, let _loginId = savedUserData["loginId"] as? Int {
                email = _email
                loginId = _loginId
                self.loginID_tf.text = "\(loginId)"
            }
        }
    }
    
    @IBAction func cancel_action(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func login_action(_ sender: Any) {
        UserDefaults.standard.set((self.password_tf.text ?? ""), forKey: "password")
        viewModel.loginForPassword(pass: self.password_tf.text ?? "")
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        self.password_tf.isSecureTextEntry = !self.password_tf.isSecureTextEntry
        self.Btn_showHidePass.setImage(!self.password_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
}
    
