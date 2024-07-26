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

class SignUpViewController: UIViewController {
    
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
    
    @IBOutlet weak var btn_termsCondition: UIButton!
    @IBOutlet weak var btn_passowrdIcon: UIButton!
    @IBOutlet weak var btn_reTpyePassowrdIcon: UIButton!
    @IBOutlet weak var btn_contiune: UIButton!
    
    var viewModel = SignViewModel()
    
    init(SignInViewModel: SignViewModel) {
        self.viewModel = SignInViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.email_tf.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
        self.password_tf.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
        self.reTypePassword_tf.addTarget(self, action: #selector(reTypePasswordTextChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func emailTextChanged(_ textField: UITextField) {
        if self.viewModel.isValidEmail(self.email_tf.text!)  {
            self.lbl_emailValid.isHidden = true
        } else {
            self.lbl_emailValid.textColor = .red
            self.lbl_emailValid.text = "email is not correct"
            self.lbl_emailValid.isHidden = false
        }
        self.enableLoginButton()
    }
    
    @objc func passwordTextChanged(_ textField: UITextField) {
        
        if self.viewModel.isPasswordValid(self.password_tf.text!)  {
            self.lbl_passValid.isHidden = true
            
        } else {
            self.lbl_passValid.isHidden = false
            self.lbl_passValid.text = "Password must be 6 character"
            self.lbl_passValid.textColor = .red
        }
        
        self.enableLoginButton()
    }
    @objc func reTypePasswordTextChange(_ textField: UITextField) {
        if self.password_tf.text == self.reTypePassword_tf.text {
            self.lbl_reTypePassValid.isHidden = true
            enableLoginButton()
        } else {
            self.lbl_reTypePassValid.isHidden = false
            self.btn_contiune.isEnabled = false
            self.btn_contiune.setTitleColor(UIColor(named: "lightGray"), for: .normal)
        }
    }
    
    private func enableLoginButton() {
        if self.viewModel.isLoginFieldsValid(email: self.email_tf.text!, password: self.reTypePassword_tf.text!)  {
            self.btn_contiune.isEnabled = true
            self.btn_contiune.setTitleColor(UIColor(named: "white"), for: .normal)
        } else {
            self.btn_contiune.isEnabled = false
            self.btn_contiune.setTitleColor(UIColor(named: "lightGray"), for: .normal)
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
        signUp()
        
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
        
        guard let clientID = GIDSignIn.sharedInstance.configuration?.clientID else {
            print("ClientID not configured.")
            return
        }
        
        //        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            
            guard let user1 = result?.user else { return }
            
            // Perform any operations on signed in user here.
            print("User signed in: \(user1.profile?.name ?? "No name")")
            self?.authenticateWithFirebase(user: user1)
            
            
        }
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
    
    
    private func authenticateWithFirebase(user: GIDGoogleUser) {
        
        let idToken = user.idToken?.tokenString
        let accessToken = user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken ?? "", accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase authentication failed: \(error.localizedDescription)")
                return
            }
            
            // User is signed in with Firebase
            if let user = authResult?.user {
                print("User signed in with Firebase: \(user.email ?? "No email")")
                
                let currentUser = Auth.auth().currentUser
                
                if currentUser != nil {
                    print("Current User ID: \(currentUser?.uid)")
                    print("Current User Email: \(currentUser?.email ?? "No email")")
                    self.navigateToDashboardScreen()
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
        
        // Check if user already exists in Firestore
        let db = Firestore.firestore()
        db.collection("usersModel").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking for existing user: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = querySnapshot, !snapshot.isEmpty {
                print("User with this email already exists.")
                self.lbl_emailValid.isHidden = false
                self.lbl_emailValid.text = "The email address is already in use by another account"
                return
            } else {
                // Use Firebase Authentication to create a new user
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
                    // Successfully created user
                    if let user = authResult?.user {
                        UserDefaults.standard.set(user.uid, forKey: "userID")
                        
                        self?.saveAdditionalUserData(userId: user.uid, firstName: firstName, lastName: lastName, phone: "", email: email, password: password, emailVerified: false, phoneVerified: false, isLogin: false, isPushToCRM: false)
                        // Navigate to the main screen or any other action
                        //                        self?.navigateToDashboardScreen()
                    }
                }
            }
        }
        
    }
    
    private func saveAdditionalUserData(userId: String, firstName: String, lastName: String, phone: String, email: String, password: String, emailVerified: Bool, phoneVerified:Bool, isLogin:Bool, isPushToCRM:Bool) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "firstName": firstName,
            "lastName": lastName,
            "phone": phone,
            "password": password,
            "emailVerified": emailVerified,
            "phoneVerified": phoneVerified,
            "isLogin": isLogin,
            "isPushToCRM": isPushToCRM
        ]) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully.")
            }
        }
    }
    
    private func navigateToDashboardScreen() {
        if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
            self.navigate(to: dashboardVC)
        }
    }
    
}
