//
//  SignUpViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//
import Foundation
import UIKit
import TPKeyboardAvoiding
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth

class SignUpViewController: BaseViewController {
    
    
    @IBOutlet weak var lbl_firstName: UITextField!
    @IBOutlet weak var lbl_lastName: UITextField!
    
    @IBOutlet weak var lbl_emailValid: UILabel!
    @IBOutlet weak var lbl_passValid: UILabel!
    @IBOutlet weak var lbl_reTypePassValid: UILabel!
    
    @IBOutlet weak var reTypePassword_tf: UITextField! {
        didSet{
            reTypePassword_tf.setIcon(UIImage(imageLiteralResourceName: "passwordIcon"))
            reTypePassword_tf.tintColor = UIColor.lightGray
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
    
    @IBOutlet weak var signinbutton: UIButton!
    @IBOutlet weak var btn_termsCondition: UIButton!
    @IBOutlet weak var btn_passowrdIcon: UIButton!
    @IBOutlet weak var btn_reTpyePassowrdIcon: UIButton!
    @IBOutlet weak var btn_contiune: UIButton!
    
    var viewModel = SignViewModel()
    var odooClientService = OdooClient()
    var odoClientNew = OdooClientNew()
    
    let db = Firestore.firestore()
    let fireBaseService =  FirestoreServices()
    
    var emailUser: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("odoo client auth call")
        //        odooClientService.authenticate()
        odoClientNew.authenticate()
        odooClientService.createLeadDelegate = self
        // Do any additional setup after loading the view.
        self.email_tf.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
        self.password_tf.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
        self.reTypePassword_tf.addTarget(self, action: #selector(reTypePasswordTextChange), for: .editingChanged)
        self.signinbutton.setTitle("", for: .normal)
        enableLoginButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
    @objc func emailTextChanged(_ textField: UITextField) {
        if self.viewModel.isValidEmail(self.email_tf.text!)  {
            self.lbl_emailValid.isHidden = true
            emailUser = self.email_tf.text!
        } else {
            self.lbl_emailValid.textColor = .red
            self.lbl_emailValid.text = "email is not correct"
            self.lbl_emailValid.isHidden = false
        }
        
    }
    
    @objc func passwordTextChanged(_ textField: UITextField) {
        
//        if self.viewModel.isPasswordValid(self.password_tf.text!)  {
//            self.lbl_passValid.isHidden = true
//            
//        } else {
//            self.lbl_passValid.isHidden = false
//            self.lbl_passValid.text = "Password must be 6 character"
//            self.lbl_passValid.textColor = .red
//        }
        
        if self.viewModel.isValidatePassword(password: self.password_tf.text!) {
            self.lbl_passValid.isHidden = true
        }else{
            self.lbl_passValid.isHidden = false
            self.lbl_passValid.text = "Password is atleast 8 character with 1 capital & 1 Special & 1 number"
            self.lbl_passValid.textColor = .red
        }
        
    }
    @objc func reTypePasswordTextChange(_ textField: UITextField) {
        if self.password_tf.text == self.reTypePassword_tf.text {
            self.lbl_reTypePassValid.isHidden = true
            
        } else {
            self.lbl_reTypePassValid.isHidden = false
            self.btn_contiune.isEnabled = false
            self.btn_contiune.setTitleColor(UIColor(named: "lightGray"), for: .normal)
        }
    }
    
    private func enableLoginButton() {
        if self.viewModel.isLoginFieldsValid(email: self.email_tf.text!, password: self.reTypePassword_tf.text!), self.btn_termsCondition.isSelected == true  {
            self.btn_contiune.isEnabled = true
            self.btn_contiune.setTitleColor(UIColor(named: "white"), for: .normal)
        } else {
            self.btn_contiune.isEnabled = false
            self.btn_contiune.setTitleColor(UIColor(named: "lightGray"), for: .normal)
        }
        
        guard let email = email_tf.text, !email.isEmpty, let password = password_tf.text, !password.isEmpty else {
            self.btn_contiune.isEnabled = false
            self.btn_contiune.setTitleColor(UIColor(named: "lightGray"), for: .normal)
            return
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
        
        if btn_termsCondition.isSelected == true {
            enableLoginButton()
        }else{
            enableLoginButton()
        }
    }
    
    @IBAction func continueBtn(_ sender: Any) {
        signUp()
        //        if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
        //            self.navigate(to: dashboardVC)
        //        }
        
        //        let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen2, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen2
        //        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        self.password_tf.isSecureTextEntry = !self.password_tf.isSecureTextEntry
        self.btn_passowrdIcon.setImage(!self.password_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func reTypePasswordIconAction(_ sender: Any) {
        self.reTypePassword_tf.isSecureTextEntry = !self.reTypePassword_tf.isSecureTextEntry
        self.btn_reTpyePassowrdIcon.setImage(!self.reTypePassword_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func continueGoogleBtn(_ sender: Any) {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            print("result user: \(result)")
            guard let user1 = result?.user else { return }
            
            self?.authenticateWithFirebase(user: user1)
            
        }
    }
    
    @IBAction func termConditionBtn(_ sender: Any) {
        if let termConditionVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "TermsConditionsViewController") {
            self.navigate(to: termConditionVC)
        }
        
    }
    @IBAction func privacyPolicyBtn(_ sender: Any) {
        if let privcyVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "PrivacyViewController") {
            self.navigate(to: privcyVC)
        }
    }
    
    
    private func authenticateWithFirebase(user: GIDGoogleUser) {
        
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
                        self.fireBaseService.fetchUserData(userId: user.uid)
                        
                        let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                            print("Timer fired!")
                            self.fireBaseService.handleUserData()
                        }
                        
                        
                    } else {
                        self.odooClientService.createRecords(firebase_uid: user.uid, email: user.email ?? "", name: user.displayName ?? "")
                        
                        self.saveAdditionalUserData(userId: user.uid, kyc: false, profileStep: 0, name: user.displayName ?? "No name", phone: "", email: user.email ?? "", emailVerified: false, phoneVerified: false, loginId: 0, login: false, pushedToCRM: false, demoAccountGroup: "", realAccountCreated: false, demoAccountCreated: false)
                        
                    }
                }
                
                
            }
        }
    }
    
    private func signUp() {
        guard
            let firstName = lbl_firstName.text, !firstName.isEmpty,
            let lastName = lbl_lastName.text, !lastName.isEmpty,
            let reTypePass = reTypePassword_tf.text, !reTypePass.isEmpty,
            let email = email_tf.text, !email.isEmpty,
            let password = password_tf.text, !password.isEmpty
                
        else {
            print("Please fill in all fields.")
            self.lbl_emailValid.isHidden = false
            self.lbl_emailValid.text = "Please fill in all fields."
            return
        }
        UserDefaults.standard.set(lbl_firstName.text, forKey: "firstName")
        UserDefaults.standard.set(lbl_lastName.text, forKey: "lastName")
        // Check if user already exists in Firestore
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking for existing user: \(error.localizedDescription)")
                
            }
            
            if let snapshot = querySnapshot, !snapshot.isEmpty {
                print("User with this email already exists.")
                self.lbl_emailValid.isHidden = false
                self.lbl_emailValid.text = "The email address is already in use by another account"
                
            } else {
                //if user is not exist then Use Firebase Authentication to create a new user
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                    if let error = error as NSError? {
                        if let authError = AuthErrorCode.Code(rawValue: error.code){
                            switch authError {
                            case .emailAlreadyInUse:
                                self?.lbl_emailValid.isHidden = false
                                self?.lbl_emailValid.text = "The email address is already in use by another account"
                                print("The email address is already in use by another account.")
                            default:
                                print("Error creating user: \(error.localizedDescription)")
                            }
                        }
                        return
                    }
                    // Successfully add user to firebase
                    if let user = authResult?.user {
                        UserDefaults.standard.set(user.uid, forKey: "userID")
                        
                        ActivityIndicator.shared.show(in: self!.view)
                        
                        let name = firstName + " " + lastName
                        self?.odooClientService.createRecords(firebase_uid: user.uid, email: email, name: name)
                        
                        self?.saveAdditionalUserData(userId: user.uid, kyc: false, profileStep: 0, name: name, phone: "", email: email, emailVerified: false, phoneVerified: false, loginId: 0, login: false, pushedToCRM: false, demoAccountGroup: "", realAccountCreated: false, demoAccountCreated: false)
                        // Navigate to the main screen or any other action
                        
                        
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
        fireBaseService.fetchUserData(userId: userId)
    }
    
    private func navigateToVerifiyScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
        //        verifyVC.userEmail = self.email_tf.text ?? ""
        GlobalVariable.instance.userEmail = self.emailUser ?? ""
        verifyVC.isEmailVerification = true
        verifyVC.isPhoneVerification = false
        self.navigate(to: verifyVC)
    }
    
}

extension SignUpViewController:  CreateLeadOdooDelegate {
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

