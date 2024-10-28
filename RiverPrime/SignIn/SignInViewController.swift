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
import GoogleSignIn

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
   
    @IBOutlet weak var btn_submit: UIButton!
    
    @IBOutlet weak var hideShowPassBtn: UIButton!
    
    let firebase = FirestoreServices()
    var viewModel = SignViewModel()
//    var signUpVC = SignUpViewController()
    var odooClientService = OdooClient()
    var odoClientNew = OdooClientNew()
    var emailUser: String?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odooClientService.createLeadDelegate = self
        // Do any additional setup after loading the view.
        
        self.username_tf.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
        self.password_tf.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
        enableLoginButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //MARK: - Show Navigation Bar
//        self.setNavBar(vc: self, isBackButton: true, isBar: true)
//        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .white, barColor: .clear)
      
//        username_tf.text = "asimprime900@gmail.com"
//        password_tf.text = "asdasd"
        
    }
    
    private func enableLoginButton() {
        if self.viewModel.isLoginFieldsValid(email: self.username_tf.text!, password: self.password_tf.text!) && self.username_tf.state.isEmpty && self.password_tf.state.isEmpty {
            self.btn_submit.isEnabled = true
            self.btn_submit.setTitleColor(UIColor(named: "white"), for: .normal)
        } else {
            self.btn_submit.isEnabled = false
            self.btn_submit.setTitleColor(UIColor(named: "lightGray"), for: .normal)
        }
        
        guard let email = username_tf.text, !email.isEmpty, let password = password_tf.text, !password.isEmpty else {
            self.btn_submit.isEnabled = false
            self.btn_submit.setTitleColor(UIColor(named: "lightGray"), for: .normal)
            return
           }
    }
    
    @objc func emailTextChanged(_ textField: UITextField) {
        if self.viewModel.isValidEmail(self.username_tf.text!) {
            self.lbl_emailCheck.isHidden = true
        } else {
            
            self.lbl_emailCheck.text = "email is not correct"
            self.lbl_emailCheck.isHidden = false
        }
        enableLoginButton()
    }
    
    @objc func passwordTextChanged(_ textField: UITextField) {
    
        if self.viewModel.isValidatePassword(password: self.password_tf.text!)  {
            self.lbl_passwordCheck.isHidden = true
        }else{
            self.lbl_passwordCheck.isHidden = false
            self.lbl_passwordCheck.text = "Password is atleast 8 character with 1 capital & 1 Special & 1 number"
        }
        enableLoginButton()
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
    
    @IBAction func signINGoogle_action(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
//            print("result user: \(result)")
            guard let user1 = result?.user else { return }
            
            self?.authenticateWithFirebase(user: user1)
            
        }
        
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
    
    func authenticateWithFirebase(user: GIDGoogleUser) {
        
        let idToken = user.idToken?.tokenString
        let accessToken = user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken ?? "", accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase authentication failed: \(error.localizedDescription)")
                return
            }
            
            // User is signed in with Firebase successfuly
            if let user = authResult?.user {
                
                UserDefaults.standard.set(user.uid, forKey: "userID")
                self.emailUser = user.email ?? ""
                
                self.db.collection("users").whereField("email", isEqualTo: self.emailUser ?? "").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error checking for existing user: \(error.localizedDescription)")
                    }
                    
                    if let snapshot = querySnapshot, !snapshot.isEmpty {
                        print("User with this email already exists.")
                        self.firebase.fetchUserData(userId: user.uid)
                        
                        let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                            print("Timer fired!")
                            self.firebase.handleUserData()
                        }
                        
                        
                    } else {
                        self.odooClientService.createRecords(firebase_uid: user.uid, email: user.email ?? "", name: user.displayName ?? "")
                        
                        self.saveAdditionalUserData(userId: user.uid, kyc: false, profileStep: 0, name: user.displayName ?? "No name", phone: "", email: user.email ?? "", emailVerified: false, phoneVerified: false, loginId: 0, login: false, pushedToCRM: false, demoAccountGroup: "", realAccountCreated: false, demoAccountCreated: false)
                        
                    }
                }
                
                
            }
        }
    }
    
    private func saveAdditionalUserData(userId: String, kyc: Bool, profileStep: Int, name: String, phone: String, email: String, emailVerified: Bool, phoneVerified:Bool, loginId: Int, login:Bool, pushedToCRM:Bool, demoAccountGroup: String, realAccountCreated: Bool, demoAccountCreated: Bool) {
        
        db.collection("users").document(userId).setData([
            "KYC" : kyc,
            "profileStep" : profileStep,
            "uid": userId,
            "name": name,
            "email":email,
            "phone": phone,
            "loginId": loginId,
            "emailVerified": emailVerified,
            "phoneVerified": phoneVerified,
            "login": login,
            "demoAccountGroup": demoAccountGroup,
            "pushedToCRM": pushedToCRM,
            "realAccountCreated": realAccountCreated,
            "demoAccountCreated": demoAccountCreated
        ]) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully.")
            }
        }
        firebase.fetchUserData(userId: userId)
    }
    
     func navigateToVerifiyScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
        //        verifyVC.userEmail = self.email_tf.text ?? ""
        GlobalVariable.instance.userEmail = self.emailUser ?? ""
        verifyVC.isEmailVerification = true
        verifyVC.isPhoneVerification = false
        self.navigate(to: verifyVC)
    }
    
}

extension SignInViewController:  CreateLeadOdooDelegate {
    func leadCreatSuccess(response: Any) {
        print("this is success response from create Lead :\(response)")
        odoClientNew.sendOTP(type: "email", email: emailUser ?? "", phone: "")
        self.ToastMessage("Check email inbox or spam for OTP")
        self.navigateToVerifiyScreen()
    }
    
    func leadCreatFailure(error: any Error) {
        print("this is error response:\(error)")
    }
    
}
