//
//  LoginPopupVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/10/2024.
//

import UIKit

enum MetaTraderType {
    case Balance
    case GetBalance
    case None
}

class LoginPopupVC: BaseViewController {

    @IBOutlet weak var login_popupView: UIView!
    
    @IBOutlet weak var loginID_tf: UITextField!{
        didSet{
//            loginID_tf.setIcon(UIImage(systemName: "iphone.and.arrow.forward.outward")!)
            if let iconImage = UIImage(systemName: "iphone.and.arrow.forward.outward") {
                loginID_tf.setIcon(iconImage)
            } else {
                print("Failed to load system image")
            }
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
    
    @IBOutlet weak var lbl_wrongPassword: UILabel!
    var email: String?
    var loginId: Int?
    
    var viewModel = TradeTypeCellVM()
    var metaTraderType: MetaTraderType? = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_wrongPassword.isHidden = true
        // Do any additional setup after loading the view.
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String, let _loginId = savedUserData["loginId"] as? Int {
                email = _email
                loginId = _loginId
                self.loginID_tf.text = "\(loginId ?? 0)"
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func cancel_action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func login_action(_ sender: Any) {
      
        viewModel.loginForPassword(pass: self.password_tf.text ?? "", completion: { response in
            print("the login to meta Trader account response is: \(response)")
            self.ToastMessage(response)
            if response == "Login Failed" {
                self.lbl_wrongPassword.isHidden = false
            }else{
                //            NotificationCenter.default.post(name: .MetaTraderLogin, object: nil,  userInfo: ["MetaTraderLoginType": self.metaTraderType ?? MetaTraderType.None])
                NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.MetaTraderLoginConstant.key, dict: [NotificationObserver.Constants.MetaTraderLoginConstant.title: self.metaTraderType ?? MetaTraderType.None])
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        self.password_tf.isSecureTextEntry = !self.password_tf.isSecureTextEntry
        self.Btn_showHidePass.setImage(!self.password_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
}
    
