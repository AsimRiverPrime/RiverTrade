//
//  LoginPopupVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/10/2024.
//

import UIKit
import FirebaseFirestore

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
    
   
    var loginId = Int()
    var isDemo = Bool()
    var userID = String()
    
    var viewModel = TradeTypeCellVM()
    var metaTraderType: MetaTraderType? = .None
    let passwordManager = PasswordManager()
    let firestoreObject = FirestoreServices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_wrongPassword.isHidden = true
        // Do any additional setup after loading the view.
       
        self.loginID_tf.text = "\(loginId)"
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
      
        viewModel.loginForPassword(loginID: loginId, pass: self.password_tf.text ?? "", isDemo: isDemo, completion: { response in
            print("the login to meta Trader account response is: \(response)")
        
            
            self.ToastMessage(response)
            if response == "Login Failed" {
                self.lbl_wrongPassword.isHidden = false
            }else{
              
                self.firestoreObject.updatePassword(for: "\(self.loginId)", userId:  self.userID, newPassword: self.password_tf.text ?? "") { [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        print("Error updating default account: \(error.localizedDescription)")
                        return
                    }
                    print("password added successfully.")
                    self.firestoreObject.updateDefaultAccount(for: "\(self.loginId)", userId: self.userID){ [weak self] error in
                        guard let self = self else { return }
                        
                        if let error = error {
                            print("Error updating default account: \(error.localizedDescription)")
                            return
                        }
                        print("\n updating isDefault account success in loginScreen: ")
                        if self.passwordManager.savePassword(for: String(self.loginId), password: self.password_tf.text ?? "") {
                            print("Password successfully saved from loginScreen.")
                        } else {
                            print("ID already exists. Cannot save password.")
                        }
                        
                        let allPasswords = self.passwordManager.getAllPasswords()
                        print("All Saved Passwords on from loginScreen: \(allPasswords)")
                        
                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.MetaTraderLoginConstant.key, dict: [NotificationObserver.Constants.MetaTraderLoginConstant.title: self.metaTraderType ?? MetaTraderType.None])
                        self.dismiss(animated: true, completion: nil)
                    }
                }

                    }
                })
                
                
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        self.password_tf.isSecureTextEntry = !self.password_tf.isSecureTextEntry
        self.Btn_showHidePass.setImage(!self.password_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
}
    
