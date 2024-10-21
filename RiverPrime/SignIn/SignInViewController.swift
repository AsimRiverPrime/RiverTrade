//
//  SignInViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//
import Foundation
import UIKit
import TPKeyboardAvoiding
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: BaseViewController {
    
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
    @IBOutlet weak var lbl_emailCheck: UILabel!
    @IBOutlet weak var lbl_passwordCheck: UILabel!
    @IBOutlet weak var lbl_credientailCheck: UILabel!
    @IBOutlet weak var btn_rememberMe: UIButton!
    
    @IBOutlet weak var hideShowPassBtn: UIButton!
    
    let firebase = FirestoreServices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //MARK: - Show Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .white, barColor: .splashScreen)
      
        username_tf.text = "asimprime900@gmail.com"
        password_tf.text = "asdasd"
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
        login()
    }
    
    @IBAction func forgotBtn(_ sender: Any) {
        if let forgotVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "ForgotViewController"){
            self.navigate(to: forgotVC)
        }
    }
    
    @IBAction func createAccountBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func login() {
        // Check if all text fields are filled
        guard
            let email = username_tf.text, !email.isEmpty
        else {
            lbl_emailCheck.text = "Please enter email."
            lbl_emailCheck.isHidden = false
            return
        }
        guard
            let password = password_tf.text, !password.isEmpty
        else {
            lbl_passwordCheck.text = "Please enter password."
            lbl_passwordCheck.isHidden = false
            return
        }
        
        // MARK: - check user verified email and number
//        firebase.getUserDataByEmail(email: email) { result in
//            switch result {
//            case .success(let data):
//                print("User data: \(data)")
//                if let isEmailVerified = data["emailVerified"] as? Bool, isEmailVerified {
//                          print("User email is active: \(isEmailVerified)")
//                      } else {
//                          print("User email is not active ")
//                          print("User move to the email verification screen")
//                      }
//                      
//                      // Additional conditions can be checked here
//                      if let isPhoneVerified = data["phoneVerified"] as? String {
//                          print("User phone is verify: \(isPhoneVerified)")
//                      } else {
//                          print("User move to the phone verification screen")
//                      }
//            case .failure(let error):
//                print("Error getting user data: \(error.localizedDescription)")
//            }
//        }
        
        // Use Firebase Authentication to sign in
        Auth.auth().signIn(withEmail: username_tf.text!, password: password_tf.text!) { [weak self] authResult, error in
            
            let authres = authResult?.user.email
            
            if let error = error as NSError? {
                if let authError = AuthErrorCode.Code(rawValue: error.code) {
                    print("Error code: \(authError)")
                    switch authError {
                        
                    case .invalidEmail:
                        self?.lbl_emailCheck.text = "Please enter correct email."
                        self?.lbl_emailCheck.isHidden = false
                    case .wrongPassword:
                        self?.lbl_passwordCheck.text = "Please enter correct password."
                        self?.lbl_passwordCheck.isHidden = false
                    case .userNotFound:
                        self?.lbl_emailCheck.text = "No account found for this email."
                        self?.lbl_emailCheck.isHidden = false
                    default:
                        self?.lbl_passwordCheck.text = "Please enter correct crediential."
                        self?.lbl_passwordCheck.isHidden = false
                        print("Error signing in: \(error.localizedDescription)")
                        return
                    }
                    
                }
            }else{
                self?.lbl_emailCheck.isHidden = true
                self?.lbl_passwordCheck.isHidden = true
                self?.lbl_credientailCheck.isHidden = true
                print(" signing in successfully: \(authres ?? " no data")")
               
                print(" signing in successfully and move to Dashboard screen ")
                
                if let userId = authResult?.user.uid {
                    self?.firebase.fetchUserData(userId: userId)
                }
                
                let timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
                    print("Timer fired!")
                    self?.firebase.handleUserData()
                }
            }
        }
        
    }
//    
//   
//    private func navigateToDashboardScreen() {
//        if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
//            self.navigate(to: dashboardVC)
//        }
//    }
}
